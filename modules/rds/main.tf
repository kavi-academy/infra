locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

resource "random_password" "db_password" {
  count   = var.enable_rds ? 1 : 0
  length  = 16
  special = false
}

resource "aws_ssm_parameter" "db_password" {
  count       = var.enable_rds ? 1 : 0
  name        = "/${var.project_name}/${var.environment}/database/password"
  description = "Master password for RDS database"
  type        = "SecureString"
  value       = random_password.db_password[0].result

  tags = local.common_tags
}

resource "aws_db_subnet_group" "db" {
  count      = var.enable_rds ? 1 : 0
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-subnet-group"
  })
}

resource "aws_db_parameter_group" "db" {
  count  = var.enable_rds ? 1 : 0
  name   = "${local.name_prefix}-mysql8-params"
  family = "mysql8.0"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  tags = local.common_tags
}

resource "aws_db_instance" "db" {
  count                  = var.enable_rds ? 1 : 0
  identifier             = "${local.name_prefix}-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.db_instance_class
  allocated_storage      = var.allocated_storage
  storage_type           = "gp2"
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.db_password[0].result
  db_subnet_group_name   = aws_db_subnet_group.db[0].name
  parameter_group_name   = aws_db_parameter_group.db[0].name
  vpc_security_group_ids = [var.rds_security_group_id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false

  lifecycle {
    ignore_changes = [password]
    postcondition {
      condition     = self.allocated_storage <= 20
      error_message = "Allocated storage must not exceed 20 GB to remain within AWS Free Tier."
    }
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rds"
  })
}
