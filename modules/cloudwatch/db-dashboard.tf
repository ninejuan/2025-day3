resource "aws_cloudwatch_dashboard" "db_dashboard" {
  dashboard_name = "${var.prefix}-db-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_identifier, { "label" = "RDS CPU %" }]]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "RDS CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.rds_instance_identifier, { "label" = "DB Connections" }]]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "RDS Connections"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", var.dynamodb_table_name, { "label" = "DDB Read (Sum)", "stat" = "Sum" }]]
          period = 60
          stat   = "Sum"
          region = "ap-northeast-2"
          title  = "DDB Read Capacity"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [["AWS/DynamoDB", "ConsumedWriteCapacityUnits", "TableName", var.dynamodb_table_name, { "label" = "DDB Write (Sum)", "stat" = "Sum" }]]
          period = 60
          stat   = "Sum"
          region = "ap-northeast-2"
          title  = "DDB Write Capacity"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [["AWS/DynamoDB", "SuccessfulRequestLatency", "TableName", var.dynamodb_table_name, "Operation", "GetItem", { "label" = "GetItem Latency" }]]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "DDB GetItem Latency"
          yAxis = { left = { min = 0 } }
          annotations = { horizontal = [
            { label = "Target 50ms", value = 50, color = "#ff7f0e" }
          ]}
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [["AWS/DynamoDB", "ThrottledRequests", "TableName", var.dynamodb_table_name, { "label" = "Throttled Requests (Sum)", "stat" = "Sum" }]]
          period = 60
          stat   = "Sum"
          region = "ap-northeast-2"
          title  = "DDB Throttled Requests"
        }
      }
    ]
  })
}

