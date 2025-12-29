# 🌩️ AWS EKS Terraform Configuration
# Secure DevSecOps Cloud Platform on AWS EKS

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
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
  
  backend "s3" {
    bucket = "secure-devsecops-tfstate"
    key    = "eks-cluster/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Data sources for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC Configuration
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  
  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr
  
  azs             = data.aws_availability_zones.available.names
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs
  
  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  # Security Groups
  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    DevSecOps   = "Enabled"
  }
}

# EKS Cluster
resource "aws_eks_cluster" "this" {
  name     = "${var.project_name}-eks-${var.environment}"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.eks_version
  
  vpc_config {
    subnet_ids = concat(module.vpc.private_subnets, module.vpc.public_subnets)
    
    # Security Configuration
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.public_access_cidrs
    
    # Network Security
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }
  
  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_key.arn
    }
    resources = ["secrets"]
  }
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
    Name        = "${var.project_name}-eks-${var.environment}"
    DevSecOps   = "Enabled"
    Security    = "Enhanced"
  }
}

# EKS Node Groups
resource "aws_eks_node_group" "private_nodes" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project_name}-private-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = module.vpc.private_subnets
  
  # Instance Configuration
  instance_types = var.node_instance_types
  
  # Capacity Configuration
  capacity_type  = "SPOT"
  scaling_config {
    desired_size = var.private_node_desired_capacity
    max_size     = var.private_node_max_capacity
    min_size     = var.private_node_min_capacity
  }
  
  # Security Configuration
  update_config {
    max_unavailable_percentage = 25
  }
  
  # Taints for specialized workloads
  taint {
    key    = "secure-platform.tier"
    value  = "backend"
    effect = "NO_SCHEDULE"
  }
  
  # Labels for node identification
  labels = {
    Environment = var.environment
    NodeType    = "private"
    Security    = "enhanced"
  }
  
  # Security Groups
  remote_access {
    ec2_ssh_key = aws_key_pair.eks_key.key_name
  }
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
    DevSecOps   = "Enabled"
  }
}

# 🔐 IAM Roles and Policies
# EKS Cluster Role
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_name}-eks-cluster-role-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
    DevSecOps   = "Enabled"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS Node Role
resource "aws_iam_role" "eks_node_role" {
  name = "${var.project_name}-eks-node-role-${var.environment}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
    DevSecOps   = "Enabled"
  }
}

resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# 🔐 Security Groups
# EKS Cluster Security Group
resource "aws_security_group" "eks_cluster_sg" {
  name_prefix = "${var.project_name}-eks-cluster-sg-"
  vpc_id      = module.vpc.vpc_id
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow HTTPS from nodes
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes_sg.id]
  }
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
    Name        = "${var.project_name}-eks-cluster-sg"
  }
}

# EKS Nodes Security Group
resource "aws_security_group" "eks_nodes_sg" {
  name_prefix = "${var.project_name}-eks-nodes-sg-"
  vpc_id      = module.vpc.vpc_id
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow all communication within the group
  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [self.id]
  }
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
    Name        = "${var.project_name}-eks-nodes-sg"
  }
}

# 🔐 KMS Key for EKS Encryption
resource "aws_kms_key" "eks_key" {
  description             = "EKS cluster encryption key for ${var.project_name}"
  deletion_window_in_days = 7
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
    DevSecOps   = "Enabled"
  }
}

resource "aws_kms_alias" "eks_key_alias" {
  name          = "alias/${var.project_name}-eks-key-${var.environment}"
  target_key_id = aws_kms_key.eks_key.key_id
}

# 🔑 EC2 Key Pair
resource "aws_key_pair" "eks_key" {
  key_name   = "${var.project_name}-eks-key-${var.environment}"
  public_key = var.ssh_public_key
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# ☁️ CloudWatch Log Group
resource "aws_cloudwatch_log_group" "eks_logs" {
  name              = "/aws/eks/${var.project_name}/cluster-${var.environment}"
  retention_in_days = 30
  
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# 🚀 Outputs
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = aws_security_group.eks_cluster_sg.id
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = aws_iam_role.eks_cluster_role.name
}

output "vpc_id" {
  description = "ID of the VPC where the cluster is deployed"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

