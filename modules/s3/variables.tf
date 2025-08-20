variable "prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "bucket_suffix" {
  description = "Random suffix for S3 bucket name"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable versioning for S3 bucket"
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error"
  type        = bool
  default     = false
}

variable "block_public_access" {
  description = "Enable block public access for S3 bucket"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
