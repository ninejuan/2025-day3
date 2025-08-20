resource "aws_dynamodb_table" "product" {
  name         = "${var.prefix}-product-table"
  billing_mode = "PROVISIONED"
  hash_key     = "id"
  
  read_capacity  = 50000
  write_capacity = 10000
  
  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "partition_key"
    type = "S"
  }

  attribute {
    name = "name"
    type = "S"
  }

  global_secondary_index {
    name            = "NameIndex"
    hash_key        = "name"
    read_capacity   = 25000
    write_capacity  = 5000
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "PartitionIndex"
    hash_key        = "partition_key"
    range_key       = "id"
    read_capacity   = 25000
    write_capacity  = 5000
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  stream_enabled                   = true
  stream_view_type                = "NEW_AND_OLD_IMAGES"
  deletion_protection_enabled     = var.enable_deletion_protection
  table_class                     = "STANDARD"
  
  tags = merge(var.common_tags, {
    Name    = "${var.prefix}-product-table"
    Service = "Product"
  })

  replica {
    region_name = "us-west-2"
  }

  replica {
    region_name = "eu-west-1"
  }
}

resource "aws_dynamodb_contributor_insights" "product" {
  table_name = aws_dynamodb_table.product.name
}

