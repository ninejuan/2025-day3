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


# ALB 5XX Count Alarms (strict; any 5XX triggers)
resource "aws_cloudwatch_metric_alarm" "alb_target_5xx" {
  count               = var.alb_arn_suffix != "" ? 1 : 0
  alarm_name          = "${var.prefix}-alb-target-5xx"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = "0"
  treat_missing_data  = "notBreaching"
  alarm_description   = "ALB target 5XX > 0"
  alarm_actions       = var.sns_alarm_topic_arn != null ? [var.sns_alarm_topic_arn] : []

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }
}
