variable "prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for monitoring"
  type        = string
}

variable "rds_instance_identifier" {
  description = "RDS instance identifier for monitoring"
  type        = string
}

variable "sns_alarm_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  type        = string
  default     = null
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for monitoring"
  type        = string
  default     = ""
}

variable "user_target_group_arn_suffix" {
  description = "User service target group ARN suffix"
  type        = string
  default     = ""
}

variable "product_target_group_arn_suffix" {
  description = "Product service target group ARN suffix"
  type        = string
  default     = ""
}

variable "stress_target_group_arn_suffix" {
  description = "Stress service target group ARN suffix"
  type        = string
  default     = ""
}

variable "ecs_cluster_name" {
  description = "ECS cluster name for monitoring"
  type        = string
  default     = ""
}

variable "ecs_service_names" {
  description = "ECS service names for monitoring"
  type = object({
    user    = string
    product = string
    stress  = string
  })
  default = {
    user    = ""
    product = ""
    stress  = ""
  }
}
