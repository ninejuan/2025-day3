variable "prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for RDS subnet group"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "bastion_security_group_id" {
  description = "Security group ID of bastion host for management access"
  type        = string
  default     = null
}

variable "database_name" {
  description = "Initial database name"
  type        = string
  default     = "userdb"
}

variable "master_username" {
  description = "Master username for RDS instance"
  type        = string
  default     = "admin"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for RDS instance"
  type        = bool
  default     = true
}



variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
