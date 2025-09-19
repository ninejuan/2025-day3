resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-ecs-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-ecs-cluster"
  })
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [aws_ecs_capacity_provider.main.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.main.name
  }
}

resource "aws_ecs_capacity_provider" "main" {
  name = "${var.prefix}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_autoscaling_group" "ecs" {
  name                = "${var.prefix}-ecs-asg"
  desired_capacity    = var.min_size
  max_size            = var.max_size
  min_size            = var.min_size
  target_group_arns   = []
  vpc_zone_identifier = var.private_subnet_ids
  health_check_type   = "EC2"
  health_check_grace_period = 300
  protect_from_scale_in = true

  launch_template {
    id      = aws_launch_template.ecs.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value              = true
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value              = "${var.prefix}-ecs-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value              = var.common_tags["Environment"]
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value              = var.common_tags["Project"]
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value              = var.common_tags["ManagedBy"]
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_scale_up" {
  name                   = "${var.prefix}-cpu-scale-up"
  scaling_adjustment     = 3
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 120
  autoscaling_group_name = aws_autoscaling_group.ecs.name
}

resource "aws_autoscaling_policy" "cpu_scale_down" {
  name                   = "${var.prefix}-cpu-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_autoscaling_group.ecs.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.prefix}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "180"
  statistic           = "Average"
  threshold           = "60"
  alarm_description   = "Scale up if CPU > 60% for 3 minutes"
  alarm_actions       = [aws_autoscaling_policy.cpu_scale_up.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
  }
}

resource "aws_launch_template" "ecs" {
  name_prefix   = "${var.prefix}-ecs-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  key_name = aws_key_pair.ecs.key_name

  vpc_security_group_ids = [aws_security_group.ecs.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs.name
  }

  user_data = base64encode("#!/bin/bash\necho 'ECS_CLUSTER=${aws_ecs_cluster.main.name}' >> /etc/ecs/ecs.config")

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.ebs_volume_size
      volume_type           = "gp3"
      delete_on_termination = true
      encrypted             = true
    }
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.prefix}-ecs-instance"
    })
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-ecs-launch-template"
  })
}

resource "aws_security_group" "ecs" {
  name_prefix = "${var.prefix}-ecs-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all inbound traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-ecs-security-group"
  })
}

resource "aws_key_pair" "ecs" {
  key_name   = "${var.prefix}-ecs-key"
  public_key = file("${path.module}/ecs_key.pub")

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-ecs-key-pair"
  })
}

resource "aws_iam_role" "ecs" {
  name = "${var.prefix}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-ecs-instance-role"
  })
}

resource "aws_iam_instance_profile" "ecs" {
  name = "${var.prefix}-ecs-instance-profile"
  role = aws_iam_role.ecs.name
}

resource "aws_iam_role_policy_attachment" "ecs" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ssm" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Additional SSM Session Manager policy for interactive access
resource "aws_iam_role_policy" "ecs_ssm_session" {
  name = "${var.prefix}-ecs-ssm-session-policy"
  role = aws_iam_role.ecs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:StartSession",
          "ssm:SendCommand",
          "ssm:ListCommandInvocations",
          "ssm:DescribeInstanceInformation",
          "ssm:DescribeDocumentParameters",
          "ssm:DescribeDocument",
          "ssm:GetCommandInvocation"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2messages:AcknowledgeMessage",
          "ec2messages:DeleteMessage",
          "ec2messages:FailMessage",
          "ec2messages:GetEndpoint",
          "ec2messages:GetMessages",
          "ec2messages:SendReply"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_cloudwatch" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_ecr" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "ecs_s3" {
  role       = aws_iam_role.ecs.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
