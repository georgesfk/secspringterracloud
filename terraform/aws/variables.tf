# 🌩️ AWS EKS Variables
# Variables for Secure DevSecOps Cloud Platform

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "secure-devsecops-cloud"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "eks_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.28"
}

variable "public_access_cidrs" {
  description = "CIDR blocks allowed to access the public EKS endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_instance_types" {
  description = "List of instance types for EKS nodes"
  type        = list(string)
  default     = ["m5.large", "m5.xlarge", "m5.2xlarge"]
}

variable "private_node_desired_capacity" {
  description = "Desired number of nodes in the private node group"
  type        = number
  default     = 2
}

variable "private_node_max_capacity" {
  description = "Maximum number of nodes in the private node group"
  type        = number
  default     = 5
}

variable "private_node_min_capacity" {
  description = "Minimum number of nodes in the private node group"
  type        = number
  default     = 1
}

variable "ssh_public_key" {
  description = "SSH public key for accessing EKS nodes"
  type        = string
}

