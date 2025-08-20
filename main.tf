locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
  
  s3_bucket_suffix = random_string.s3_suffix.result
}

# Random string for S3 bucket naming
resource "random_string" "s3_suffix" {
  length  = 8
  special = false
  upper   = false
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  prefix      = var.prefix
  vpc_cidr    = var.vpc_cidr
  common_tags = local.common_tags

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# VPC Endpoints Module
module "vpc_endpoints" {
  source = "./modules/vpc-endpoints"

  prefix                    = var.prefix
  vpc_id                    = module.vpc.vpc_id
  vpc_cidr_block           = module.vpc.vpc_cidr_block
  private_subnet_ids       = module.vpc.private_subnet_ids
  private_route_table_ids  = module.vpc.private_route_table_ids
  common_tags              = local.common_tags
}

# Bastion Module
module "bastion" {
  source = "./modules/bastion"

  prefix            = var.prefix
  vpc_id            = module.vpc.vpc_id
  vpc_cidr_block   = module.vpc.vpc_cidr_block
  public_subnet_ids = module.vpc.public_subnet_ids
  instance_type     = var.bastion_instance_type
  ssh_port         = var.ssh_port
  common_tags      = local.common_tags
}

# DynamoDB Module
module "dynamodb" {
  source = "./modules/dynamodb"

  prefix                     = var.prefix
  enable_deletion_protection = var.enable_deletion_protection
  common_tags               = local.common_tags
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  prefix                    = var.prefix
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  private_subnet_cidrs      = var.private_subnet_cidrs
  bastion_security_group_id = module.bastion.bastion_security_group_id
  database_name             = var.rds_database_name
  master_username           = var.rds_username
  enable_deletion_protection = var.enable_deletion_protection
  common_tags              = local.common_tags
}

# CloudWatch Module
module "cloudwatch" {
  source = "./modules/cloudwatch"

  prefix                   = var.prefix
  dynamodb_table_name      = module.dynamodb.table_name
  rds_instance_identifier  = module.rds.rds_instance_id
  sns_alarm_topic_arn      = null
  common_tags             = local.common_tags
}