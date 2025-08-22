output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "capacity_provider_name" {
  description = "Name of the ECS capacity provider"
  value       = aws_ecs_capacity_provider.main.name
}

output "auto_scaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.ecs.name
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.ecs.id
}

output "security_group_id" {
  description = "ID of the ECS security group"
  value       = aws_security_group.ecs.id
}

output "key_pair_name" {
  description = "Name of the SSH key pair"
  value       = aws_key_pair.ecs.key_name
}

output "iam_role_arn" {
  description = "ARN of the ECS instance IAM role"
  value       = aws_iam_role.ecs.arn
}

output "user_task_definition_arn" {
  description = "ARN of the user task definition"
  value       = aws_ecs_task_definition.user.arn
}

output "product_task_definition_arn" {
  description = "ARN of the product task definition"
  value       = aws_ecs_task_definition.product.arn
}

output "stress_task_definition_arn" {
  description = "ARN of the stress task definition"
  value       = aws_ecs_task_definition.stress.arn
}

output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task_role.arn
}
