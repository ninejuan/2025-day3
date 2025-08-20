# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = module.vpc.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = module.vpc.private_subnet_cidrs
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = module.vpc.nat_gateway_ids
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = module.vpc.public_route_table_id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = module.vpc.private_route_table_ids
}

# VPC Endpoints Outputs
output "s3_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = module.vpc_endpoints.s3_endpoint_id
}

output "dynamodb_endpoint_id" {
  description = "ID of the DynamoDB VPC endpoint"
  value       = module.vpc_endpoints.dynamodb_endpoint_id
}

output "ecr_endpoints" {
  description = "ECR VPC endpoint IDs"
  value = {
    ecr_dkr = module.vpc_endpoints.ecr_dkr_endpoint_id
    ecr_api = module.vpc_endpoints.ecr_api_endpoint_id
  }
}

output "ecs_endpoints" {
  description = "ECS VPC endpoint IDs"
  value = {
    ecs           = module.vpc_endpoints.ecs_endpoint_id
    ecs_agent     = module.vpc_endpoints.ecs_agent_endpoint_id
    ecs_telemetry = module.vpc_endpoints.ecs_telemetry_endpoint_id
  }
}

output "monitoring_endpoints" {
  description = "Monitoring VPC endpoint IDs"
  value = {
    logs       = module.vpc_endpoints.logs_endpoint_id
    monitoring = module.vpc_endpoints.monitoring_endpoint_id
  }
}

output "ssm_endpoints" {
  description = "SSM VPC endpoint IDs"
  value = {
    ssm          = module.vpc_endpoints.ssm_endpoint_id
    ssm_messages = module.vpc_endpoints.ssm_messages_endpoint_id
    ec2_messages = module.vpc_endpoints.ec2_messages_endpoint_id
  }
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the security group for VPC endpoints"
  value       = module.vpc_endpoints.vpc_endpoints_security_group_id
}

# Bastion Outputs
output "bastion_instance_id" {
  description = "ID of the bastion instance"
  value       = module.bastion.bastion_instance_id
}

output "bastion_public_ip" {
  description = "Public IP address of the bastion instance"
  value       = module.bastion.bastion_public_ip
}

output "bastion_private_ip" {
  description = "Private IP address of the bastion instance"
  value       = module.bastion.bastion_private_ip
}

output "bastion_public_dns" {
  description = "Public DNS name of the bastion instance"
  value       = module.bastion.bastion_public_dns
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = module.bastion.bastion_security_group_id
}

output "bastion_key_name" {
  description = "Name of the SSH key pair for bastion"
  value       = module.bastion.bastion_key_name
}

output "bastion_ssh_connection_command" {
  description = "SSH connection command for bastion host"
  value       = module.bastion.bastion_ssh_connection_command
}

output "bastion_private_key_ssm_parameter" {
  description = "SSM parameter name containing the private key"
  value       = module.bastion.bastion_private_key_ssm_parameter
  sensitive   = true
}

# DynamoDB Outputs
output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = module.dynamodb.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = module.dynamodb.dynamodb_table_arn
}

output "dynamodb_gsi_name" {
  description = "Name of the Global Secondary Index"
  value       = module.dynamodb.dynamodb_gsi_name
}

output "product_app_environment_variables" {
  description = "Environment variables for the product application"
  value       = module.dynamodb.product_app_environment_variables
}

# RDS Outputs
output "rds_instance_id" {
  description = "ID of the RDS instance"
  value       = module.rds.rds_instance_id
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.rds_endpoint
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.rds_port
}

output "rds_database_name" {
  description = "Name of the initial database"
  value       = module.rds.rds_database_name
}

output "rds_master_username" {
  description = "Master username for the RDS instance"
  value       = module.rds.rds_master_username
}

output "rds_password_ssm_parameter" {
  description = "SSM parameter name containing the RDS master password"
  value       = module.rds.rds_password_ssm_parameter
  sensitive   = true
}

output "user_app_environment_variables" {
  description = "Environment variables for the user application"
  value       = module.rds.user_app_environment_variables
  sensitive   = true
}

output "rds_connection_info" {
  description = "RDS connection information"
  value       = module.rds.connection_info
}

# CloudWatch Outputs
output "cloudwatch_alarm_arns" {
  description = "List of all CloudWatch alarm ARNs"
  value       = module.cloudwatch.alarm_arns
}

output "dynamodb_alarms" {
  description = "DynamoDB CloudWatch alarm ARNs"
  value = {
    throttled_requests = module.cloudwatch.dynamodb_throttled_requests_alarm_arn
    latency           = module.cloudwatch.dynamodb_latency_alarm_arn
    read_capacity     = module.cloudwatch.dynamodb_read_capacity_alarm_arn
  }
}

output "rds_alarms" {
  description = "RDS CloudWatch alarm ARNs"
  value = {
    cpu_utilization = module.cloudwatch.rds_cpu_alarm_arn
    connections     = module.cloudwatch.rds_connections_alarm_arn
  }
}
