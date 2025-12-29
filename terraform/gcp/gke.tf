# ☁️ GCP GKE Terraform Configuration
# Secure DevSecOps Cloud Platform on Google Cloud GKE

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }
  
  backend "gcs" {
    bucket = "secure-devsecops-tfstate"
    prefix = "gke-cluster"
  }
}

# Provider Configuration
provider "google" {
  project = var.project_id
  region  = var.gcp_region
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com"
  ])
  
  project = var.project_id
  service = each.value
  
  disable_dependent_services = false
  disable_on_destroy        = false
}

# 🌍 VPC Network Configuration
resource "google_compute_network" "vpc_network" {
  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
  
  depends_on = [google_project_service.required_apis]
}

# 🔒 Subnet for GKE cluster
resource "google_compute_subnetwork" "gke_subnet" {
  name          = "${var.project_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.gcp_region
  network       = google_compute_network.vpc_network.id
  
  # Secondary ranges for pods and services
  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }
  
  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
  
  # Private Google Access
  private_ip_google_access = true
  
  # Flow logs for network monitoring
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling       = 0.5
    metadata           = "INCLUDE_ALL_METADATA"
  }
}

# 🔐 Firewall Rules
# Allow internal traffic within the VPC
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.project_name}-allow-internal"
  network = google_compute_network.vpc_network.name
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "icmp"
  }
  
  source_ranges = [var.subnet_cidr]
  target_tags   = ["${var.project_name}-nodes"]
}

# Allow SSH from bastion host
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.project_name}-allow-ssh"
  network = google_compute_network.vpc_network.name
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.bastion_allowed_ips
  target_tags   = ["${var.project_name}-bastion"]
}

# Allow HTTPS traffic
resource "google_compute_firewall" "allow_https" {
  name    = "${var.project_name}-allow-https"
  network = google_compute_network.vpc_network.name
  
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.project_name}-load-balancer"]
}

# Allow health checks
resource "google_compute_firewall" "allow_health_check" {
  name    = "${var.project_name}-allow-health-check"
  network = google_compute_network.vpc_network.name
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  
  source_ranges = [
    "130.211.0.0/22",  # Google Cloud health checks
    "35.191.0.0/16"
  ]
  target_tags = ["${var.project_name}-nodes"]
}

# 🔑 GKE Cluster
resource "google_container_cluster" "primary_cluster" {
  name     = "${var.project_name}-gke-${var.environment}"
  location = var.gcp_region
  
  # Network configuration
  network    = google_compute_network.vpc_network.name
  subnetwork = google_compute_subnetwork.gke_subnet.name
  
  # Secondary ranges for pods and services
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }
  
  # Network policy
  network_policy {
    enabled = true
  }
  
  # Addons configuration
  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }
    
    network_policy_config {
      disabled = false
    }
    
    dns_cache_config {
      enabled = true
    }
  }
  
  # Logging and monitoring
  logging_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS",
      "API_SERVER"
    ]
  }
  
  monitoring_config {
    enable_components = [
      "SYSTEM_COMPONENTS",
      "WORKLOADS"
    ]
    
    managed_prometheus {
      enabled = true
    }
  }
  
  # Security configuration
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    
    master_global_access_config {
      enabled = true
    }
    
    master_ipv4_cidr_block = "172.16.0.0/28"
  }
  
  # Security settings
  resource_labels = {
    project     = var.project_name
    environment = var.environment
    devsecops   = "enabled"
    security    = "enhanced"
  }
  
  # Maintenance policy
  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }
  
  # Remove default node pool
  remove_default_node_pool = true
  initial_node_count       = 1
  
  # Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # Database encryption
  database_encryption {
    state    = "ENCRYPTED"
    key_name = google_kms_crypto_key.gke_key.id
  }
  
  depends_on = [google_project_service.required_apis]
}

# 🔐 Node Pool Configuration
resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.project_name}-node-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.primary_cluster.name
  
  # Autoscaling configuration
  autoscaling {
    min_node_count = var.min_nodes
    max_node_count = var.max_nodes
  }
  
  # Management configuration
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  
  # Node configuration
  node_config {
    preemptible  = true
    machine_type = var.machine_type
    disk_size_gb = var.disk_size
    disk_type    = "pd-ssd"
    
    # Service account
    service_account = google_service_account.gke_nodes.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
    
    # Metadata
    metadata = {
      disable-legacy-endpoints = "true"
    }
    
    # Shielded instance configuration
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
    
    # Workload metadata configuration
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    
    tags = ["${var.project_name}-nodes"]
  }
  
  # Upgrade settings
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
  
  # Timeouts
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

# 🔑 Service Account for GKE Nodes
resource "google_service_account" "gke_nodes" {
  account_id   = "${var.project_name}-gke-nodes"
  display_name = "GKE Nodes Service Account"
  description  = "Service account for GKE nodes in ${var.project_name} cluster"
}

# IAM roles for GKE nodes service account
resource "google_project_iam_member" "gke_nodes_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer"
  ])
  
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

# 🔐 KMS Key for Encryption
resource "google_kms_key_ring" "gke_keyring" {
  name     = "${var.project_name}-gke-keyring"
  location = var.gcp_region
}

resource "google_kms_crypto_key" "gke_key" {
  name     = "${var.project_name}-gke-key"
  key_ring = google_kms_key_ring.gke_keyring.id

  rotation_period = "7776000s" # 90 days
}

# Grant GKE service account access to KMS key
resource "google_kms_crypto_key_iam_member" "gke_key_user" {
  crypto_key_id = google_kms_crypto_key.gke_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.project.number}@container-engine-robot.iam.gserviceaccount.com"
}

# 🔒 Bastion Host (Optional)
resource "google_compute_instance" "bastion" {
  name         = "${var.project_name}-bastion"
  machine_type = "e2-micro"
  zone         = var.bastion_zone
  
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 10
    }
  }
  
  network_interface {
    network    = google_compute_network.vpc_network.name
    subnetwork = google_compute_subnetwork.gke_subnet.name
    
    access_config {
      nat_ip = google_compute_address.bastion_ip.address
    }
  }
  
  tags = ["${var.project_name}-bastion"]
  
  metadata = {
    enable-oslogin = "true"
  }
  
  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y kubectl
    gcloud components install gke-gcloud-auth-plugin
    echo 'export USE_GKE_GCLOUD_AUTH_PLUGIN=True' >> ~/.bashrc
  EOF
  
  depends_on = [google_project_service.required_apis]
}

# Static IP for bastion host
resource "google_compute_address" "bastion_ip" {
  name = "${var.project_name}-bastion-ip"
}

# 🔍 Monitoring and Alerting
resource "google_monitoring_alert_policy" "cluster_health" {
  display_name = "GKE Cluster Health Alert"
  combiner     = "OR"
  enabled      = true
  
  conditions {
    display_name = "Cluster condition"
    
    condition_threshold {
      filter          = "resource.type=\"gke_cluster\" AND resource.labels.cluster_name=\"${google_container_cluster.primary_cluster.name}\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0.5
      duration        = "300s"
      
      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_RATE"
        cross_series_reducer = "REDUCE_MEAN"
      }
    }
  }
  
  notification_channels = [var.notification_channel]
  
  alert_strategy {
    auto_close = "86400s" # 24 hours
  }
}

# 📊 Outputs
output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.primary_cluster.name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.primary_cluster.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = google_container_cluster.primary_cluster.master_auth.0.cluster_ca_certificate
  sensitive   = true
}

output "bastion_ip" {
  description = "Bastion host IP address"
  value       = google_compute_address.bastion_ip.address
}

output "node_pool_name" {
  description = "Node pool name"
  value       = google_container_node_pool.primary_nodes.name
}

output "vpc_network_id" {
  description = "VPC network ID"
  value       = google_compute_network.vpc_network.id
}

output "subnet_id" {
  description = "Subnet ID"
  value       = google_compute_subnetwork.gke_subnet.id
}

# Data sources
data "google_project" "project" {
  project_id = var.project_id
}

