variable "prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where bastion will be created"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.medium"
  
  validation {
    condition     = var.instance_type == "t3.medium"
    error_message = "Bastion instance type must be t3.medium."
  }
}

variable "ssh_port" {
  description = "SSH port for bastion host"
  type        = number
  default     = 22
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
