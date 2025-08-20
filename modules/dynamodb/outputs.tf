output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.product.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.product.arn
}

output "dynamodb_table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.product.id
}

output "dynamodb_gsi_name" {
  description = "Name of the Global Secondary Index"
  value       = "NameIndex"
}

output "dynamodb_stream_arn" {
  description = "ARN of the DynamoDB stream"
  value       = aws_dynamodb_table.product.stream_arn
}

# Environment variables for product application
output "product_app_environment_variables" {
  description = "Environment variables for the product application"
  value = {
    TABLE_NAME       = aws_dynamodb_table.product.name
    TABLE_INDEX_NAME = "NameIndex"
  }
}

# Performance metrics outputs
output "cloudwatch_alarms" {
  description = "CloudWatch alarm names for monitoring"
  value = {
    read_capacity      = aws_cloudwatch_metric_alarm.dynamodb_consumed_read_capacity.alarm_name
    write_capacity     = aws_cloudwatch_metric_alarm.dynamodb_consumed_write_capacity.alarm_name
    throttled_requests = aws_cloudwatch_metric_alarm.dynamodb_throttled_requests.alarm_name
    high_latency       = aws_cloudwatch_metric_alarm.dynamodb_successful_request_latency.alarm_name
  }
}

# Data source for current region
data "aws_region" "current" {}
