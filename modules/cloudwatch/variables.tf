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
