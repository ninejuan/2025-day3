resource "aws_ecs_task_definition" "user" {
  family                   = "${var.prefix}-user-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "user"
      image = "${var.ecr_user_repository_url}:v1"
      
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "MYSQL_USER"
          value = var.mysql_user
        },
        {
          name  = "MYSQL_PASSWORD"
          value = var.mysql_password
        },
        {
          name  = "MYSQL_HOST"
          value = var.mysql_host
        },
        {
          name  = "MYSQL_PORT"
          value = tostring(var.mysql_port)
        },
        {
          name  = "MYSQL_DBNAME"
          value = var.mysql_dbname
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.user.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }

      stopTimeout = 90
      startTimeout = 60

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/healthcheck || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      essential = true
    }
  ])

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-user-task-definition"
  })
}

resource "aws_ecs_task_definition" "product" {
  family                   = "${var.prefix}-product-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "product"
      image = "${var.ecr_product_repository_url}:v1"
      
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "TABLE_NAME"
          value = var.dynamodb_table_name
        },
        {
          name  = "TABLE_INDEX_NAME"
          value = var.dynamodb_table_index_name
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.product.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }

      stopTimeout = 90
      startTimeout = 60

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/healthcheck || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      essential = true
    }
  ])

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-product-task-definition"
  })
}

resource "aws_ecs_task_definition" "stress" {
  family                   = "${var.prefix}-stress-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = 1024
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "stress"
      image = "${var.ecr_stress_repository_url}:v1"
      
      portMappings = [
        {
          containerPort = 8080
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.stress.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "ecs"
        }
      }

      stopTimeout = 120
      startTimeout = 60

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8080/healthcheck || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      essential = true
    }
  ])

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-stress-task-definition"
  })
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.prefix}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-ecs-task-execution-role"
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-ecs-task-role"
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_dynamodb" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_rds" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_cloudwatch" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_cloudwatch_log_group" "user" {
  name              = "/ecs/${var.prefix}-user"
  retention_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-user-log-group"
  })
}

resource "aws_cloudwatch_log_group" "product" {
  name              = "/ecs/${var.prefix}-product"
  retention_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-product-log-group"
  })
}

resource "aws_cloudwatch_log_group" "stress" {
  name              = "/ecs/${var.prefix}-stress"
  retention_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-stress-log-group"
  })
}

data "aws_region" "current" {}
