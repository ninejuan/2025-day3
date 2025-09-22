variable "prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "origin_domain_name" {
  description = "Origin domain name (ALB DNS name)"
  type        = string
}

variable "default_ttl" {
  description = "Default TTL for cached objects (seconds)"
  type        = number
  default     = 30
}

variable "min_ttl" {
  description = "Minimum TTL for cached objects (seconds)"
  type        = number
  default     = 0
}

variable "max_ttl" {
  description = "Maximum TTL for cached objects (seconds)"
  type        = number
  default     = 180
}

variable "user_min_ttl" {
  description = "Minimum TTL for user path (seconds)"
  type        = number
  default     = 0
}

variable "user_default_ttl" {
  description = "Default TTL for user path (seconds)"
  type        = number
  default     = 30
}

variable "user_max_ttl" {
  description = "Maximum TTL for user path (seconds)"
  type        = number
  default     = 180
}

variable "product_min_ttl" {
  description = "Minimum TTL for product path (seconds)"
  type        = number
  default     = 0
}

variable "product_default_ttl" {
  description = "Default TTL for product path (seconds)"
  type        = number
  default     = 600
}

variable "product_max_ttl" {
  description = "Maximum TTL for product path (seconds)"
  type        = number
  default     = 3600
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_200"
}

variable "enabled" {
  description = "Whether the distribution is enabled"
  type        = bool
  default     = true
}

variable "comment" {
  description = "Comment for the distribution"
  type        = string
  default     = "API CloudFront distribution"
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}


