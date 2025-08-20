resource "random_password" "master_password" {
  length  = 16
  special = true
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.prefix}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-rds-subnet-group"
  })
}

resource "aws_security_group" "rds" {
  name_prefix = "${var.prefix}-rds-"
  vpc_id      = var.vpc_id

  ingress {
    description = "MySQL from private subnets"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  ingress {
    description     = "MySQL from bastion"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.bastion_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-rds-sg"
  })
}

resource "aws_db_parameter_group" "main" {
  family = "mysql8.0"
  name   = "${var.prefix}-mysql80-params"

  parameter {
    name  = "innodb_buffer_pool_size"
    value = "{DBInstanceClassMemory*3/4}"
  }

  parameter {
    name  = "max_connections"
    value = "100"
  }

  parameter {
    name  = "innodb_flush_log_at_trx_commit"
    value = "0"
  }

  parameter {
    name  = "sync_binlog"
    value = "0"
  }

  parameter {
    name  = "tmp_table_size"
    value = "134217728"
  }

  parameter {
    name  = "max_heap_table_size"
    value = "134217728"
  }

  parameter {
    name  = "thread_cache_size"
    value = "50"
  }

  parameter {
    name  = "table_open_cache"
    value = "1000"
  }

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-mysql80-params"
  })
}

# IAM Role for RDS Enhanced Monitoring
resource "aws_iam_role" "rds_monitoring" {
  name = "${var.prefix}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-rds-monitoring-role"
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_option_group" "main" {
  name                     = "${var.prefix}-rds-option-group"
  engine_name              = "mysql"
  major_engine_version     = "8.0"
  option_group_description = "Option group for MySQL 8.0"

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-rds-option-group"
  })
}

resource "aws_db_instance" "main" {
  identifier                        = "${var.prefix}-rds-instance"
  engine                           = "mysql"
  engine_version                   = "8.0.43"
  instance_class                   = "db.t3.micro"
  allocated_storage                = 20
  storage_type                     = "gp3"
  multi_az                         = true
  db_subnet_group_name             = aws_db_subnet_group.main.name
  vpc_security_group_ids           = [aws_security_group.rds.id]
  db_name                          = var.database_name
  username                         = var.master_username
  password                         = random_password.master_password.result
  port                             = 3306
  publicly_accessible              = false
  skip_final_snapshot              = true
  deletion_protection              = var.enable_deletion_protection
  backup_retention_period          = 7
  performance_insights_enabled     = false
  monitoring_interval              = 60
  monitoring_role_arn              = aws_iam_role.rds_monitoring.arn
  parameter_group_name             = aws_db_parameter_group.main.name
  option_group_name                = aws_db_option_group.main.name

  tags = merge(var.common_tags, {
    Name    = "${var.prefix}-rds-instance"
    Service = "User"
  })
}

resource "aws_ssm_parameter" "rds_password" {
  name        = "/${var.prefix}/rds/master-password"
  description = "RDS master password for ${var.prefix}-rds-instance"
  type        = "SecureString"
  value       = random_password.master_password.result
  overwrite   = true

  tags = merge(var.common_tags, {
    Name = "${var.prefix}-rds-master-password"
  })
}

