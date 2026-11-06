output "db_endpoint" {
  description = "Connection endpoint for the RDS MySQL instance"
  value       = var.enable_rds ? aws_db_instance.db[0].endpoint : null
}

output "db_address" {
  description = "Hostname of the RDS instance"
  value       = var.enable_rds ? aws_db_instance.db[0].address : null
}

output "db_port" {
  description = "Port the database is listening on"
  value       = var.enable_rds ? aws_db_instance.db[0].port : null
}

output "db_password_ssm_arn" {
  description = "SSM Parameter Store ARN containing the database master password"
  value       = var.enable_rds ? aws_ssm_parameter.db_password[0].arn : null
}
