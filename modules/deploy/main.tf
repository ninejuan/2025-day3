resource "aws_lb" "main" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-alb"
  })
}

resource "aws_security_group" "alb" {
  name_prefix = "${var.prefix}-alb-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-alb-security-group"
  })
}

resource "aws_lb_target_group" "user" {
  name        = "${var.prefix}-user-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/healthcheck"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-user-target-group"
  })
}

resource "aws_lb_target_group" "product" {
  name        = "${var.prefix}-product-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/healthcheck"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-product-target-group"
  })
}

resource "aws_lb_target_group" "stress" {
  name        = "${var.prefix}-stress-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/healthcheck"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-stress-target-group"
  })
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.prefix}-main-listener"
  })
}

resource "aws_lb_listener_rule" "user" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 100

  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.user.arn
      }
    }
  }

  condition {
    path_pattern {
      values = ["/v1/user*"]
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-user-rule"
  })
}

resource "aws_lb_listener_rule" "product" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 200

  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.product.arn
      }
    }
  }

  condition {
    path_pattern {
      values = ["/v1/product*"]
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-product-rule"
  })
}

resource "aws_lb_listener_rule" "stress" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 300

  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.stress.arn
      }
    }
  }

  condition {
    path_pattern {
      values = ["/v1/stress*"]
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-stress-rule"
  })
}

resource "aws_lb_listener_rule" "healthcheck" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 400

  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.product.arn
      }
    }
  }

  condition {
    path_pattern {
      values = ["/healthcheck*"]
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-healthcheck-rule"
  })
}

resource "aws_ecs_service" "user" {
  name            = "${var.prefix}-user-service"
  cluster         = var.ecs_cluster_id
  task_definition = var.user_task_definition_arn
  desired_count   = var.user_desired_count
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.user.arn
    container_name   = "user"
    container_port   = 8080
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50

  deployment_controller {
    type = "ECS"
  }

  health_check_grace_period_seconds = 60

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-user-service"
  })
}

resource "aws_ecs_service" "product" {
  name            = "${var.prefix}-product-service"
  cluster         = var.ecs_cluster_id
  task_definition = var.product_task_definition_arn
  desired_count   = var.product_desired_count
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.product.arn
    container_name   = "product"
    container_port   = 8080
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50

  deployment_controller {
    type = "ECS"
  }

  health_check_grace_period_seconds = 60

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-product-service"
  })
}

resource "aws_ecs_service" "stress" {
  name            = "${var.prefix}-stress-service"
  cluster         = var.ecs_cluster_id
  task_definition = var.stress_task_definition_arn
  desired_count   = var.stress_desired_count
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = aws_lb_target_group.stress.arn
    container_name   = "stress"
    container_port   = 8080
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50

  deployment_controller {
    type = "ECS"
  }

  health_check_grace_period_seconds = 120

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-stress-service"
  })
}

resource "aws_security_group" "ecs_service" {
  name_prefix = "${var.prefix}-ecs-service-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "ALB to ECS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-ecs-service-security-group"
  })
}

resource "aws_appautoscaling_target" "user" {
  max_capacity       = var.user_max_count
  min_capacity       = var.user_min_count
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.user.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_target" "product" {
  max_capacity       = var.product_max_count
  min_capacity       = var.product_min_count
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.product.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_target" "stress" {
  max_capacity       = var.stress_max_count
  min_capacity       = var.stress_min_count
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.stress.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "user_cpu" {
  name               = "${var.prefix}-user-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.user.resource_id
  scalable_dimension = aws_appautoscaling_target.user.scalable_dimension
  service_namespace  = aws_appautoscaling_target.user.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

resource "aws_appautoscaling_policy" "product_cpu" {
  name               = "${var.prefix}-product-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.product.resource_id
  scalable_dimension = aws_appautoscaling_target.product.scalable_dimension
  service_namespace  = aws_appautoscaling_target.product.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

resource "aws_appautoscaling_policy" "stress_cpu" {
  name               = "${var.prefix}-stress-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.stress.resource_id
  scalable_dimension = aws_appautoscaling_target.stress.scalable_dimension
  service_namespace  = aws_appautoscaling_target.stress.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

# CloudWatch Alarms for SLO Monitoring
resource "aws_cloudwatch_metric_alarm" "user_response_time" {
  alarm_name          = "${var.prefix}-user-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "0.2"
  alarm_description   = "This metric monitors user service response time SLO (0.2s target)"
  alarm_actions       = []

  dimensions = {
    TargetGroup = aws_lb_target_group.user.arn_suffix
  }

  depends_on = [aws_ecs_service.user]

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "user_response_time_critical" {
  alarm_name          = "${var.prefix}-user-response-time-critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "5.0"
  alarm_description   = "This metric monitors user service response time critical threshold (5s max)"
  alarm_actions       = []

  dimensions = {
    TargetGroup = aws_lb_target_group.user.arn_suffix
  }

  depends_on = [aws_ecs_service.user]

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "product_response_time" {
  alarm_name          = "${var.prefix}-product-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "0.2"
  alarm_description   = "This metric monitors product service response time SLO (0.2s target)"
  alarm_actions       = []

  dimensions = {
    TargetGroup = aws_lb_target_group.product.arn_suffix
  }

  depends_on = [aws_ecs_service.product]

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "product_response_time_critical" {
  alarm_name          = "${var.prefix}-product-response-time-critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "5.0"
  alarm_description   = "This metric monitors product service response time critical threshold (5s max)"
  alarm_actions       = []

  dimensions = {
    TargetGroup = aws_lb_target_group.product.arn_suffix
  }

  depends_on = [aws_ecs_service.product]

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "stress_response_time" {
  alarm_name          = "${var.prefix}-stress-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1.0"
  alarm_description   = "This metric monitors stress service response time SLO (1s target)"
  alarm_actions       = []

  dimensions = {
    TargetGroup = aws_lb_target_group.stress.arn_suffix
  }

  depends_on = [aws_ecs_service.stress]

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "stress_response_time_critical" {
  alarm_name          = "${var.prefix}-stress-response-time-critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "5.0"
  alarm_description   = "This metric monitors stress service response time critical threshold (5s max)"
  alarm_actions       = []

  dimensions = {
    TargetGroup = aws_lb_target_group.stress.arn_suffix
  }

  depends_on = [aws_ecs_service.stress]

  tags = var.common_tags
}
