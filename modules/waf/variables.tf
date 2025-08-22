variable "prefix" {
  description = "Resource prefix"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "alb_arn" {
  description = "ARN of the ALB to associate with WAF"
  type        = string
}
