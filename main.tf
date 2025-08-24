locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
  
  s3_bucket_suffix = random_string.s3_suffix.result

  ecs_min_size = 1
  ecs_max_size = 15
}

resource "random_string" "s3_suffix" {
  length  = 8
  special = false
  upper   = false
}

module "vpc" {
  source = "./modules/vpc"

  prefix      = var.prefix
  vpc_cidr    = var.vpc_cidr
  common_tags = local.common_tags

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "vpc_endpoints" {
  source = "./modules/vpc-endpoints"

  prefix                    = var.prefix
  vpc_id                    = module.vpc.vpc_id
  vpc_cidr_block           = module.vpc.vpc_cidr_block
  private_subnet_ids       = module.vpc.private_subnet_ids
  private_route_table_ids  = module.vpc.private_route_table_ids
  common_tags              = local.common_tags
}

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

module "dynamodb" {
  source = "./modules/dynamodb"

  prefix                     = var.prefix
  enable_deletion_protection = var.enable_deletion_protection
  common_tags               = local.common_tags
}

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

module "ecr" {
  source = "./modules/ecr"

  prefix      = var.prefix
  common_tags = local.common_tags
}

module "s3" {
  source = "./modules/s3"

  prefix        = var.prefix
  bucket_suffix = local.s3_bucket_suffix
  common_tags   = local.common_tags
}

module "ecs" {
  source = "./modules/ecs"

  prefix                = var.prefix
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  instance_type         = var.ecs_instance_type
  ebs_volume_size       = var.ecs_ebs_volume_size
  min_size              = local.ecs_min_size
  max_size              = local.ecs_max_size
  common_tags           = local.common_tags
  
  ecr_user_repository_url    = module.ecr.user_repository_url
  ecr_product_repository_url = module.ecr.product_repository_url
  ecr_stress_repository_url  = module.ecr.stress_repository_url
  
  mysql_user     = var.rds_username
  mysql_password = module.rds.rds_master_password
  mysql_host     = module.rds.rds_endpoint
  mysql_port     = module.rds.rds_port
  mysql_dbname   = var.rds_database_name
  
  dynamodb_table_name      = module.dynamodb.dynamodb_table_name
  dynamodb_table_index_name = module.dynamodb.dynamodb_gsi_name
}

# module "deploy" {
#   source = "./modules/deploy"

#   prefix = var.prefix
#   common_tags = local.common_tags
#   vpc_id = module.vpc.vpc_id
#   public_subnet_ids = module.vpc.public_subnet_ids
#   private_subnet_ids = module.vpc.private_subnet_ids

#   ecs_cluster_id = module.ecs.cluster_arn
#   ecs_cluster_name = module.ecs.cluster_name

#   user_task_definition_arn = module.ecs.user_task_definition_arn
#   product_task_definition_arn = module.ecs.product_task_definition_arn
#   stress_task_definition_arn = module.ecs.stress_task_definition_arn

#   user_desired_count = 2
#   user_min_count = 2
#   user_max_count = 8

#   product_desired_count = 2
#   product_min_count = 2
#   product_max_count = 20

#   stress_desired_count = 2
#   stress_min_count = 2
#   stress_max_count = 6
# }

# module "waf" {
#   source = "./modules/waf"

#   prefix = var.prefix
#   common_tags = local.common_tags
#   alb_arn = module.deploy.alb_arn

#   depends_on = [module.deploy]
# }

# module "cloudwatch" {
#   source = "./modules/cloudwatch"

#   prefix                            = var.prefix
#   dynamodb_table_name              = module.dynamodb.table_name
#   rds_instance_identifier          = module.rds.rds_instance_id
#   sns_alarm_topic_arn              = null
#   common_tags                      = local.common_tags
  
#   alb_arn_suffix                   = try(module.deploy.alb_arn_suffix, "")
#   user_target_group_arn_suffix     = try(module.deploy.user_target_group_arn_suffix, "")
#   product_target_group_arn_suffix  = try(module.deploy.product_target_group_arn_suffix, "")
#   stress_target_group_arn_suffix   = try(module.deploy.stress_target_group_arn_suffix, "")
  
#   ecs_cluster_name                 = module.ecs.cluster_name
#   ecs_service_names = {
#     user    = try(module.deploy.user_service_name, "")
#     product = try(module.deploy.product_service_name, "")
#     stress  = try(module.deploy.stress_service_name, "")
#   }
# }