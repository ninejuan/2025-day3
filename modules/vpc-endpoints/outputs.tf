output "s3_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "dynamodb_endpoint_id" {
  description = "ID of the DynamoDB VPC endpoint"
  value       = aws_vpc_endpoint.dynamodb.id
}

output "ecr_dkr_endpoint_id" {
  description = "ID of the ECR Docker VPC endpoint"
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "ecr_api_endpoint_id" {
  description = "ID of the ECR API VPC endpoint"
  value       = aws_vpc_endpoint.ecr_api.id
}

output "logs_endpoint_id" {
  description = "ID of the CloudWatch Logs VPC endpoint"
  value       = aws_vpc_endpoint.logs.id
}

output "monitoring_endpoint_id" {
  description = "ID of the CloudWatch Monitoring VPC endpoint"
  value       = aws_vpc_endpoint.monitoring.id
}

output "ecs_endpoint_id" {
  description = "ID of the ECS VPC endpoint"
  value       = aws_vpc_endpoint.ecs.id
}

output "ecs_agent_endpoint_id" {
  description = "ID of the ECS Agent VPC endpoint"
  value       = aws_vpc_endpoint.ecs_agent.id
}

output "ecs_telemetry_endpoint_id" {
  description = "ID of the ECS Telemetry VPC endpoint"
  value       = aws_vpc_endpoint.ecs_telemetry.id
}

output "ssm_endpoint_id" {
  description = "ID of the SSM VPC endpoint"
  value       = aws_vpc_endpoint.ssm.id
}

output "ssm_messages_endpoint_id" {
  description = "ID of the SSM Messages VPC endpoint"
  value       = aws_vpc_endpoint.ssm_messages.id
}

output "ec2_messages_endpoint_id" {
  description = "ID of the EC2 Messages VPC endpoint"
  value       = aws_vpc_endpoint.ec2_messages.id
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the security group for VPC endpoints"
  value       = aws_security_group.vpc_endpoints.id
}
