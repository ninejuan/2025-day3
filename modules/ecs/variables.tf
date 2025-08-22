variable "prefix" {
  description = "Resource prefix"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS instances"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for ECS instances"
  type        = string
  default     = "t3.medium"
}

variable "ebs_volume_size" {
  description = "EBS volume size in GiB"
  type        = number
  default     = 50
}

variable "min_size" {
  description = "Minimum number of instances in Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in Auto Scaling Group"
  type        = number
  default     = 10
}

variable "ecr_user_repository_url" {
  description = "ECR repository URL for user application"
  type        = string
}

variable "ecr_product_repository_url" {
  description = "ECR repository URL for product application"
  type        = string
}

variable "ecr_stress_repository_url" {
  description = "ECR repository URL for stress application"
  type        = string
}

variable "mysql_user" {
  description = "MySQL username"
  type        = string
}

variable "mysql_password" {
  description = "MySQL password"
  type        = string
  sensitive   = true
}

variable "mysql_host" {
  description = "MySQL host"
  type        = string
}

variable "mysql_port" {
  description = "MySQL port"
  type        = number
  default     = 3306
}

variable "mysql_dbname" {
  description = "MySQL database name"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "dynamodb_table_index_name" {
  description = "DynamoDB table index name"
  type        = string
}
