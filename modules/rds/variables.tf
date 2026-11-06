variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "kavi-devops"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "enable_rds" {
  description = "Whether to provision the RDS database instance"
  type        = bool
  default     = false
}

variable "db_instance_class" {
  description = "RDS instance class (free-tier eligible: db.t3.micro or db.t2.micro)"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB (Free tier covers up to 20 GB)"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Name of the default MySQL database to create"
  type        = string
  default     = "expenses"
}

variable "db_username" {
  description = "Master username for MySQL"
  type        = string
  default     = "dbadmin"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for DB Subnet Group"
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "Security Group ID for RDS"
  type        = string
}

variable "tags" {
  description = "Additional tags for RDS resources"
  type        = map(string)
  default     = {}
}
