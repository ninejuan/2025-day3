variable "prefix" {
  description = "Resource name prefix"
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

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for ECS services"
  type        = list(string)
}

variable "ecs_cluster_id" {
  description = "ECS cluster ID"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "user_task_definition_arn" {
  description = "User task definition ARN"
  type        = string
}

variable "product_task_definition_arn" {
  description = "Product task definition ARN"
  type        = string
}

variable "stress_task_definition_arn" {
  description = "Stress task definition ARN"
  type        = string
}

variable "user_desired_count" {
  description = "Desired number of user service tasks"
  type        = number
  default     = 3
}

variable "user_min_count" {
  description = "Minimum number of user service tasks"
  type        = number
  default     = 2
}

variable "user_max_count" {
  description = "Maximum number of user service tasks"
  type        = number
  default     = 10
}

variable "product_desired_count" {
  description = "Desired number of product service tasks"
  type        = number
  default     = 3
}

variable "product_min_count" {
  description = "Minimum number of product service tasks"
  type        = number
  default     = 2
}

variable "product_max_count" {
  description = "Maximum number of product service tasks"
  type        = number
  default     = 10
}

variable "stress_desired_count" {
  description = "Desired number of stress service tasks"
  type        = number
  default     = 2
}

variable "stress_min_count" {
  description = "Minimum number of stress service tasks"
  type        = number
  default     = 1
}

variable "stress_max_count" {
  description = "Maximum number of stress service tasks"
  type        = number
  default     = 8
}
