locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
  
  s3_bucket_suffix = random_string.s3_suffix.result
}