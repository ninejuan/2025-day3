output "dynamodb_throttled_requests_alarm_arn" {
  description = "ARN of the DynamoDB throttled requests alarm"
  value       = aws_cloudwatch_metric_alarm.dynamodb_throttled_requests.arn
}

output "dynamodb_latency_alarm_arn" {
  description = "ARN of the DynamoDB latency alarm"
  value       = aws_cloudwatch_metric_alarm.dynamodb_latency.arn
}

output "dynamodb_read_capacity_alarm_arn" {
  description = "ARN of the DynamoDB read capacity alarm"
  value       = aws_cloudwatch_metric_alarm.dynamodb_consumed_read_capacity.arn
}

output "rds_cpu_alarm_arn" {
  description = "ARN of the RDS CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.rds_cpu_utilization.arn
}

output "rds_connections_alarm_arn" {
  description = "ARN of the RDS database connections alarm"
  value       = aws_cloudwatch_metric_alarm.rds_database_connections.arn
}

output "alarm_arns" {
  description = "List of all CloudWatch alarm ARNs"
  value = [
    aws_cloudwatch_metric_alarm.dynamodb_throttled_requests.arn,
    aws_cloudwatch_metric_alarm.dynamodb_latency.arn,
    aws_cloudwatch_metric_alarm.dynamodb_consumed_read_capacity.arn,
    aws_cloudwatch_metric_alarm.rds_cpu_utilization.arn,
    aws_cloudwatch_metric_alarm.rds_database_connections.arn
  ]
}
