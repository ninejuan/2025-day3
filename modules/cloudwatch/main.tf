# DynamoDB CloudWatch Alarms
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

# RDS CloudWatch Alarms
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

# Service Monitoring Dashboard
resource "aws_cloudwatch_dashboard" "service_monitoring" {
  count = var.alb_arn_suffix != "" ? 1 : 0
  
  dashboard_name = "${var.prefix}-service-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      # SLO Response Time Metrics
      {
        type   = "metric"
        x      = 0
        y      = 0
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
      },

      # Request Count and Status Codes
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "TargetGroup", var.user_target_group_arn_suffix, { "label" = "User Requests" }],
            [".", ".", ".", var.product_target_group_arn_suffix, { "label" = "Product Requests" }],
            [".", ".", ".", var.stress_target_group_arn_suffix, { "label" = "Stress Requests" }]
          ]
          period = 60
          stat   = "Sum"
          region = "ap-northeast-2"
          title  = "📊 Request Volume"
        }
      },

      # HTTP Status Codes
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_2XX_Count", "TargetGroup", var.user_target_group_arn_suffix, { "label" = "User 2XX" }],
            [".", "HTTPCode_Target_4XX_Count", ".", ".", { "label" = "User 4XX" }],
            [".", "HTTPCode_Target_5XX_Count", ".", ".", { "label" = "User 5XX" }],
            [".", "HTTPCode_Target_2XX_Count", ".", var.product_target_group_arn_suffix, { "label" = "Product 2XX" }],
            [".", "HTTPCode_Target_4XX_Count", ".", ".", { "label" = "Product 4XX" }],
            [".", "HTTPCode_Target_5XX_Count", ".", ".", { "label" = "Product 5XX" }],
            [".", "HTTPCode_Target_2XX_Count", ".", var.stress_target_group_arn_suffix, { "label" = "Stress 2XX" }],
            [".", "HTTPCode_Target_4XX_Count", ".", ".", { "label" = "Stress 4XX" }],
            [".", "HTTPCode_Target_5XX_Count", ".", ".", { "label" = "Stress 5XX" }]
          ]
          period = 60
          stat   = "Sum"
          region = "ap-northeast-2"
          title  = "🚦 HTTP Status Codes"
        }
      },

      # Healthy/Unhealthy Target Count
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", var.user_target_group_arn_suffix, { "label" = "User Healthy" }],
            [".", "UnHealthyHostCount", ".", ".", { "label" = "User Unhealthy" }],
            [".", "HealthyHostCount", ".", var.product_target_group_arn_suffix, { "label" = "Product Healthy" }],
            [".", "UnHealthyHostCount", ".", ".", { "label" = "Product Unhealthy" }],
            [".", "HealthyHostCount", ".", var.stress_target_group_arn_suffix, { "label" = "Stress Healthy" }],
            [".", "UnHealthyHostCount", ".", ".", { "label" = "Stress Unhealthy" }]
          ]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "💚 Target Health Status"
        }
      },

      # ECS Service CPU Utilization
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", var.ecs_service_names.user, "ClusterName", var.ecs_cluster_name, { "label" = "User Service CPU" }],
            [".", ".", ".", var.ecs_service_names.product, ".", ".", { "label" = "Product Service CPU" }],
            [".", ".", ".", var.ecs_service_names.stress, ".", ".", { "label" = "Stress Service CPU" }]
          ]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "⚡ ECS Service CPU Utilization"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          annotations = {
            horizontal = [
              {
                label = "High CPU (80%)"
                value = 80
                color = "#ff7f0e"
              }
            ]
          }
        }
      },

      # ECS Service Memory Utilization
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ServiceName", var.ecs_service_names.user, "ClusterName", var.ecs_cluster_name, { "label" = "User Service Memory" }],
            [".", ".", ".", var.ecs_service_names.product, ".", ".", { "label" = "Product Service Memory" }],
            [".", ".", ".", var.ecs_service_names.stress, ".", ".", { "label" = "Stress Service Memory" }]
          ]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "💾 ECS Service Memory Utilization"
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          annotations = {
            horizontal = [
              {
                label = "High Memory (80%)"
                value = 80
                color = "#ff7f0e"
              }
            ]
          }
        }
      },

      # ECS Service Running Task Count
      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ECS", "RunningTaskCount", "ServiceName", var.ecs_service_names.user, "ClusterName", var.ecs_cluster_name, { "label" = "User Tasks" }],
            [".", ".", ".", var.ecs_service_names.product, ".", ".", { "label" = "Product Tasks" }],
            [".", ".", ".", var.ecs_service_names.stress, ".", ".", { "label" = "Stress Tasks" }]
          ]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "🏃 Running Task Count"
        }
      },

      # Database Performance
      {
        type   = "metric"
        x      = 12
        y      = 18
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

      # DynamoDB Latency
      {
        type   = "metric"
        x      = 0
        y      = 24
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
      },

      # ALB Performance Overview
      {
        type   = "metric"
        x      = 12
        y      = 24
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix, { "label" = "Total Requests" }],
            [".", "NewConnectionCount", ".", ".", { "label" = "New Connections" }],
            [".", "ActiveConnectionCount", ".", ".", { "label" = "Active Connections" }]
          ]
          period = 60
          stat   = "Sum"
          region = "ap-northeast-2"
          title  = "🌐 Load Balancer Overview"
        }
      }
    ]
  })
}
