resource "aws_cloudwatch_dashboard" "service_dashboard" {
  dashboard_name = "${var.prefix}-svc-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 8
        height = 6

        properties = {
          metrics = [["AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", var.user_target_group_arn_suffix, { "label" = "User Avg" }]]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "User SLO"
          yAxis = { left = { min = 0, max = 2 } }
          annotations = { horizontal = [
            { label = "SLO 0.2s", value = 0.2, color = "#ff7f0e" },
            { label = "Critical 5s", value = 5.0, color = "#ff0000" }
          ]}
        }
      },
      {
        type   = "metric"
        x      = 8
        y      = 0
        width  = 8
        height = 6

        properties = {
          metrics = [["AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", var.product_target_group_arn_suffix, { "label" = "Product Avg" }]]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "Product SLO"
          yAxis = { left = { min = 0, max = 2 } }
          annotations = { horizontal = [
            { label = "SLO 0.2s", value = 0.2, color = "#ff7f0e" },
            { label = "Critical 5s", value = 5.0, color = "#ff0000" }
          ]}
        }
      },
      {
        type   = "metric"
        x      = 16
        y      = 0
        width  = 8
        height = 6

        properties = {
          metrics = [["AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", var.stress_target_group_arn_suffix, { "label" = "Stress Avg" }]]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "Stress SLO"
          yAxis = { left = { min = 0, max = 2 } }
          annotations = { horizontal = [
            { label = "SLO 1.0s", value = 1.0, color = "#d62728" },
            { label = "Critical 5s", value = 5.0, color = "#ff0000" }
          ]}
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", var.user_target_group_arn_suffix, { "stat" = "p90", "label" = "User p90" }],
            [".", ".", ".", var.product_target_group_arn_suffix, { "stat" = "p90", "label" = "Product p90" }],
            [".", ".", ".", var.stress_target_group_arn_suffix, { "stat" = "p90", "label" = "Stress p90" }]
          ]
          period = 60
          region = "ap-northeast-2"
          title  = "p90 Response Time"
          yAxis = { left = { min = 0 } }
          annotations = { horizontal = [
            { label = "SLO 0.2s", value = 0.2, color = "#ff7f0e" },
            { label = "SLO 1.0s", value = 1.0, color = "#d62728" },
            { label = "Critical 5s", value = 5.0, color = "#ff0000" }
          ]}
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", var.user_target_group_arn_suffix, { "stat" = "p95", "label" = "User p95" }],
            [".", ".", ".", var.product_target_group_arn_suffix, { "stat" = "p95", "label" = "Product p95" }],
            [".", ".", ".", var.stress_target_group_arn_suffix, { "stat" = "p95", "label" = "Stress p95" }]
          ]
          period = 60
          region = "ap-northeast-2"
          title  = "p95 Response Time"
          yAxis = { left = { min = 0 } }
          annotations = { horizontal = [
            { label = "SLO 0.2s", value = 0.2, color = "#ff7f0e" },
            { label = "SLO 1.0s", value = 1.0, color = "#d62728" },
            { label = "Critical 5s", value = 5.0, color = "#ff0000" }
          ]}
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "TargetGroup", var.user_target_group_arn_suffix, { "stat" = "p99", "label" = "User p99" }],
            [".", ".", ".", var.product_target_group_arn_suffix, { "stat" = "p99", "label" = "Product p99" }],
            [".", ".", ".", var.stress_target_group_arn_suffix, { "stat" = "p99", "label" = "Stress p99" }]
          ]
          period = 60
          region = "ap-northeast-2"
          title  = "p99 Response Time"
          yAxis = { left = { min = 0 } }
          annotations = { horizontal = [
            { label = "SLO 0.2s", value = 0.2, color = "#ff7f0e" },
            { label = "SLO 1.0s", value = 1.0, color = "#d62728" },
            { label = "Critical 5s", value = 5.0, color = "#ff0000" }
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
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix, { "label" = "Requests (Sum)", "stat" = "Sum" }],
            [".", "HTTPCode_Target_5XX_Count", ".", ".", { "label" = "Target 5XX (Sum)", "stat" = "Sum" }]
          ]
          period = 60
          stat   = "Sum"
          region = "ap-northeast-2"
          title  = "Request & 5XX"
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 18
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_4XX_Count", "TargetGroup", var.user_target_group_arn_suffix, { "label" = "User 4XX" }],
            [".", ".", ".", var.product_target_group_arn_suffix, { "label" = "Product 4XX" }],
            [".", ".", ".", var.stress_target_group_arn_suffix, { "label" = "Stress 4XX" }]
          ]
          period = 60
          stat   = "Sum"
          region = "ap-northeast-2"
          title  = "Target 4XX by Service"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 18
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "TargetGroup", var.user_target_group_arn_suffix, { "label" = "User 5XX" }],
            [".", ".", ".", var.product_target_group_arn_suffix, { "label" = "Product 5XX" }],
            [".", ".", ".", var.stress_target_group_arn_suffix, { "label" = "Stress 5XX" }]
          ]
          period = 60
          stat   = "Sum"
          region = "ap-northeast-2"
          title  = "Target 5XX by Service"
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 24
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", var.user_target_group_arn_suffix, { "label" = "User Healthy" }],
            [".", ".", ".", var.product_target_group_arn_suffix, { "label" = "Product Healthy" }],
            [".", ".", ".", var.stress_target_group_arn_suffix, { "label" = "Stress Healthy" }]
          ]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "Healthy Host Count"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 24
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/ApplicationELB", "UnHealthyHostCount", "TargetGroup", var.user_target_group_arn_suffix, { "label" = "User UnHealthy" }],
            [".", ".", ".", var.product_target_group_arn_suffix, { "label" = "Product UnHealthy" }],
            [".", ".", ".", var.stress_target_group_arn_suffix, { "label" = "Stress UnHealthy" }]
          ]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "Unhealthy Host Count"
        }
      },

      {
        type   = "metric"
        x      = 0
        y      = 30
        width  = 12
        height = 6

        properties = {
          metrics = [["AWS/ApplicationELB", "ActiveConnectionCount", "LoadBalancer", var.alb_arn_suffix, { "label" = "Active Connections" }]]
          period = 60
          stat   = "Average"
          region = "ap-northeast-2"
          title  = "Active Connections"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 30
        width  = 12
        height = 6

        properties = {
          metrics = [["AWS/ApplicationELB", "NewConnectionCount", "LoadBalancer", var.alb_arn_suffix, { "label" = "New Connections (Sum)", "stat" = "Sum" }]]
          period = 60
          stat   = "Sum"
          region = "ap-northeast-2"
          title  = "New Connections"
        }
      }
    ]
  })
}

