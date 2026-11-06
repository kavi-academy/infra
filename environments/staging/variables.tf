variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS local CLI profile name (set to null/empty when running in CI/CD on EC2)"
  type        = string
  default     = ""
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "kavi-devops"
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "staging"
}

variable "aws_account_id" {
  description = "12-digit AWS Account ID"
  type        = string
  default     = "250326384271"
}

variable "vpc_cidr" {
  description = "CIDR block for the environment VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.20.11.0/24", "10.20.12.0/24"]
}

variable "instance_type" {
  description = "EC2 instance type for app server"
  type        = string
  default     = "t3.micro"
}

variable "enable_bastion" {
  description = "Enable Bastion host in public subnet"
  type        = bool
  default     = false
}

variable "enable_rds" {
  description = "Enable RDS MySQL instance"
  type        = bool
  default     = false
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "RDS allocated storage in GB (max 20 GB for free tier)"
  type        = number
  default     = 20
}

variable "image_tag" {
  description = "Application Docker image tag"
  type        = string
  default     = "latest"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH to EC2"
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = ""
}
