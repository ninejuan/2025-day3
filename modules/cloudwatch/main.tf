resource "aws_cloudwatch_metric_alarm" "dynamodb_throttled_requests" {
  alarm_name          = "${var.prefix}-dynamodb-throttled-requests"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ThrottledRequests"
  namespace           = "AWS/DynamoDB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "DynamoDB throttled requests alarm"
  alarm_actions       = var.sns_alarm_topic_arn != null ? [var.sns_alarm_topic_arn] : []

  dimensions = {
    TableName = var.dynamodb_table_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_latency" {
  alarm_name          = "${var.prefix}-dynamodb-latency-015s"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "SuccessfulRequestLatency"
  namespace           = "AWS/DynamoDB"
  period              = "60"
  statistic           = "Average"
  threshold           = "50"
  alarm_description   = "DynamoDB latency exceeding 50ms for 0.15s target"
  alarm_actions       = var.sns_alarm_topic_arn != null ? [var.sns_alarm_topic_arn] : []

  dimensions = {
    TableName = var.dynamodb_table_name
    Operation = "GetItem"
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "dynamodb_consumed_read_capacity" {
  alarm_name          = "${var.prefix}-dynamodb-read-capacity-80pct"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ConsumedReadCapacityUnits"
  namespace           = "AWS/DynamoDB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "40000"
  alarm_description   = "DynamoDB read capacity exceeding 80%"
  alarm_actions       = var.sns_alarm_topic_arn != null ? [var.sns_alarm_topic_arn] : []

  dimensions = {
    TableName = var.dynamodb_table_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_utilization" {
  alarm_name          = "${var.prefix}-rds-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "RDS CPU utilization alarm"
  alarm_actions       = var.sns_alarm_topic_arn != null ? [var.sns_alarm_topic_arn] : []

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_identifier
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "rds_database_connections" {
  alarm_name          = "${var.prefix}-rds-database-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "RDS database connections alarm"
  alarm_actions       = var.sns_alarm_topic_arn != null ? [var.sns_alarm_topic_arn] : []

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_identifier
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_dashboard" "service_monitoring" {
  dashboard_name = "${var.prefix}-service-monitoring"

  dashboard_body = jsonencode({
    widgets = concat(
      [
        {
          type   = "metric"
          x      = 0
          y      = 0
          width  = 12
          height = 6

          properties = {
            metrics = [
              ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_identifier, { "label" = "RDS CPU %" }],
              [".", "DatabaseConnections", ".", ".", { "label" = "DB Connections" }],
              ["AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", var.dynamodb_table_name, { "label" = "DynamoDB Read" }],
              [".", "ConsumedWriteCapacityUnits", ".", ".", { "label" = "DynamoDB Write" }]
            ]
            period = 60
            stat   = "Average"
            region = "ap-northeast-2"
            title  = "🗃️ Database Performance"
          }
        },
        
        {
          type   = "metric"
          x      = 12
          y      = 0
          width  = 12
          height = 6

          properties = {
            metrics = [
              ["AWS/DynamoDB", "SuccessfulRequestLatency", "TableName", var.dynamodb_table_name, "Operation", "GetItem", { "label" = "GetItem Latency" }],
              [".", ".", ".", ".", ".", "PutItem", { "label" = "PutItem Latency" }],
              [".", "ThrottledRequests", ".", ".", { "label" = "Throttled Requests" }]
            ]
            period = 60
            stat   = "Average"
            region = "ap-northeast-2"
            title  = "⚡ DynamoDB Performance"
            yAxis = {
              left = {
                min = 0
              }
            }
            annotations = {
              horizontal = [
                {
                  label = "Target Latency (50ms)"
                  value = 50
                  color = "#ff7f0e"
                }
              ]
            }
          }
        }
      ],
      
      var.alb_arn_suffix != "" ? [
        {
          type   = "metric"
          x      = 0
          y      = 6
          width  = 12
          height = 6

          properties = {
            metrics = [
              ["AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", var.user_target_group_arn_suffix, { "label" = "User Service (Target: 0.2s)" }],
              [".", ".", ".", var.product_target_group_arn_suffix, { "label" = "Product Service (Target: 0.2s)" }],
              [".", ".", ".", var.stress_target_group_arn_suffix, { "label" = "Stress Service (Target: 1.0s)" }]
            ]
            period = 60
            stat   = "Average"
            region = "ap-northeast-2"
            title  = "🎯 Service Response Time SLO"
            yAxis = {
              left = {
                min = 0
                max = 2
              }
            }
            annotations = {
              horizontal = [
                {
                  label = "User/Product SLO (0.2s)"
                  value = 0.2
                  color = "#ff7f0e"
                },
                {
                  label = "Stress SLO (1.0s)"
                  value = 1.0
                  color = "#d62728"
                },
                {
                  label = "Critical Threshold (5.0s)"
                  value = 5.0
                  color = "#ff0000"
                }
              ]
            }
          }
        }
      ] : []
    )
  })
}
