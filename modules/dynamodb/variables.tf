variable "prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for DynamoDB table"
  type        = bool
  default     = true
}

variable "enable_global_tables" {
  description = "Enable Global Tables for multi-region distribution"
  type        = bool
  default     = false
}

variable "replica_regions" {
  description = "List of replica regions for Global Tables"
  type        = list(string)
  default     = ["us-west-2", "eu-west-1"]
}

variable "kms_key_id" {
  description = "KMS key ID for DynamoDB encryption (optional for performance)"
  type        = string
  default     = null
}



variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
