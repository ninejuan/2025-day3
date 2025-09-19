resource "aws_cloudwatch_dashboard" "metrics_dashboard" {
  dashboard_name = "${var.prefix}-metrics-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_names.user, { "label" = "User CPU %" }]]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "User CPU%"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_names.user, { "label" = "User Mem %" }]]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "User Mem%"
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_names.product, { "label" = "Product CPU %" }]]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "Product CPU%"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_names.product, { "label" = "Product Mem %" }]]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "Product Mem%"
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_names.stress, { "label" = "Stress CPU %" }]]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "Stress CPU%"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_names.stress, { "label" = "Stress Mem %" }]]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "Stress Mem%"
        }
      }
    ]
  })
}

