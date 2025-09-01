variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "apdev"
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
  default     = "apdev"
}

# Instance types
variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.medium"
}

variable "ssh_port" {
  description = "SSH port for bastion host"
  type        = number
  default     = 22
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.16.0/20", "10.0.32.0/20", "10.0.48.0/20"]
}

# DynamoDB Configuration
variable "enable_deletion_protection" {
  description = "Enable deletion protection for DynamoDB table"
  type        = bool
  default     = true
}

# RDS Configuration
variable "rds_database_name" {
  description = "Initial database name for RDS"
  type        = string
  default     = "userdb"
}

variable "rds_username" {
  description = "Master username for RDS instance"
  type        = string
  default     = "admin"
}

# ECS Configuration
variable "ecs_instance_type" {
  description = "Instance type for ECS instances"
  type        = string
  default     = "t3.medium"
}

variable "ecs_ebs_volume_size" {
  description = "EBS volume size in GiB for ECS instances"
  type        = number
  default     = 50
}

variable "ecs_min_size" {
  description = "Minimum number of instances in ECS Auto Scaling Group"
  type        = number
  default     = 2
}

variable "ecs_max_size" {
  description = "Maximum number of instances in ECS Auto Scaling Group"
  type        = number
  default     = 4
}
 