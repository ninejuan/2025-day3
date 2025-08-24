resource "aws_dynamodb_table" "product" {
  name         = "${var.prefix}-product-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  
  attribute {
    name = "id"
    type = "S"
  }
  
  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  stream_enabled = false
  table_class    = "STANDARD"
  
  tags = merge(var.common_tags, {
    Name    = "${var.prefix}-product-table"
    Service = "Product"
  })
}