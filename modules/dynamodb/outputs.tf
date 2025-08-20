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

output "table_name" {
  description = "Name of the DynamoDB table for use by other modules"
  value       = aws_dynamodb_table.product.name
}
