variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "skills-competition"
}

variable "region_code" {
  description = "Region code for resource naming"
  type        = string
  default     = "sungsimdang"
}



# Instance types
variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.medium"
}

variable "jenkins_instance_type" {
  description = "Instance type for Jenkins"
  type        = string
  default     = "m5.large"
}

variable "eks_node_instance_type" {
  description = "Instance type for EKS nodes"
  type        = string
  default     = "m5.large"
}

variable "rds_instance_type" {
  description = "Instance type for RDS"
  type        = string
  default     = "db.t3.medium"
}

# EKS configuration
variable "eks_cluster_version" {
  description = "EKS cluster version"
  type        = string
  default     = "1.32"
}

variable "eks_node_min_size" {
  description = "Minimum number of EKS nodes"
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Maximum number of EKS nodes"
  type        = number
  default     = 20
}

# SSH configuration
variable "ssh_port" {
  description = "SSH port for bastion host"
  type        = number
  default     = 2580
}

# Web UI credentials
variable "web_ui_username" {
  description = "Username for web UI (Jenkins, ArgoCD)"
  type        = string
  default     = "ws-api-admin"
}

variable "web_ui_password" {
  description = "Password for web UI (Jenkins, ArgoCD)"
  type        = string
  default     = "Skills2025**"
  sensitive   = true
}

# S3 bucket random suffix
variable "s3_bucket_random_suffix" {
  description = "Random suffix for S3 bucket name"
  type        = string
  default     = "abcd"  # 실제로는 random provider를 사용해야 함
}

# RDS configuration
variable "rds_engine" {
  description = "RDS engine"
  type        = string
  default     = "mysql"
}

variable "rds_engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "5.7"
}

variable "rds_database_name" {
  description = "Initial database name"
  type        = string
  default     = "day1"
}

variable "rds_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
} 