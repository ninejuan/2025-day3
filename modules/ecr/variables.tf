variable "prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "repositories" {
  description = "List of ECR repository names to create"
  type        = list(string)
  default     = ["product", "user", "stress"]
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
