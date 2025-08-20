output "rds_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.main.id
}

output "rds_instance_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.main.arn
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "rds_database_name" {
  description = "Name of the initial database"
  value       = aws_db_instance.main.db_name
}

output "rds_master_username" {
  description = "Master username for the RDS instance"
  value       = aws_db_instance.main.username
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "rds_subnet_group_name" {
  description = "Name of the RDS subnet group"
  value       = aws_db_subnet_group.main.name
}

output "rds_parameter_group_name" {
  description = "Name of the RDS parameter group"
  value       = aws_db_parameter_group.mysql80.name
}

output "rds_password_ssm_parameter" {
  description = "SSM parameter name containing the RDS master password"
  value       = aws_ssm_parameter.rds_password.name
  sensitive   = true
}

# Connection information for applications
output "user_app_environment_variables" {
  description = "Environment variables for the user application (정확한 변수명)"
  value = {
    MYSQL_HOST     = aws_db_instance.main.endpoint
    MYSQL_PORT     = aws_db_instance.main.port
    MYSQL_DBNAME   = aws_db_instance.main.db_name
    MYSQL_USER     = aws_db_instance.main.username
    MYSQL_PASSWORD_SSM = aws_ssm_parameter.rds_password.name
  }
}

# 추가: User 앱 전용 사용자 정보
output "user_app_dedicated_user" {
  description = "Dedicated database user for user application (권장)"
  value = {
    MYSQL_HOST     = aws_db_instance.main.endpoint
    MYSQL_PORT     = aws_db_instance.main.port
    MYSQL_DBNAME   = "userdb"
    MYSQL_USER     = "userapp"
    MYSQL_PASSWORD = "UserApp2025!"
  }
  sensitive = true
}

output "connection_info" {
  description = "RDS connection information"
  value = {
    endpoint  = aws_db_instance.main.endpoint
    port      = aws_db_instance.main.port
    database  = aws_db_instance.main.db_name
    username  = aws_db_instance.main.username
    engine    = aws_db_instance.main.engine
    version   = aws_db_instance.main.engine_version
    multi_az  = aws_db_instance.main.multi_az
    instance_class = aws_db_instance.main.instance_class
  }
}

# Performance monitoring outputs
output "cloudwatch_alarms" {
  description = "CloudWatch alarm names for monitoring"
  value = {
    cpu_utilization = aws_cloudwatch_metric_alarm.rds_cpu.alarm_name
    connections     = aws_cloudwatch_metric_alarm.rds_connections.alarm_name
    freeable_memory = aws_cloudwatch_metric_alarm.rds_freeable_memory.alarm_name
  }
}
