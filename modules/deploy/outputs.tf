output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "user_target_group_arn" {
  description = "ARN of the user target group"
  value       = aws_lb_target_group.user.arn
}

output "product_target_group_arn" {
  description = "ARN of the product target group"
  value       = aws_lb_target_group.product.arn
}

output "stress_target_group_arn" {
  description = "ARN of the stress target group"
  value       = aws_lb_target_group.stress.arn
}

output "user_service_name" {
  description = "Name of the user service"
  value       = aws_ecs_service.user.name
}

output "product_service_name" {
  description = "Name of the product service"
  value       = aws_ecs_service.product.name
}

output "stress_service_name" {
  description = "Name of the stress service"
  value       = aws_ecs_service.stress.name
}

output "user_service_arn" {
  description = "ARN of the user service"
  value       = aws_ecs_service.user.id
}

output "product_service_arn" {
  description = "ARN of the product service"
  value       = aws_ecs_service.product.id
}

output "stress_service_arn" {
  description = "ARN of the stress service"
  value       = aws_ecs_service.stress.id
}

output "alb_security_group_id" {
  description = "Security group ID of the ALB"
  value       = aws_security_group.alb.id
}

output "ecs_service_security_group_id" {
  description = "Security group ID of the ECS services"
  value       = aws_security_group.ecs_service.id
}

output "service_endpoints" {
  description = "Service endpoints"
  value = {
    user    = "http://${aws_lb.main.dns_name}/v1/user"
    product = "http://${aws_lb.main.dns_name}/v1/product"
    stress  = "http://${aws_lb.main.dns_name}/v1/stress"
    healthcheck = "http://${aws_lb.main.dns_name}/healthcheck"
  }
}
