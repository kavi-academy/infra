variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "kavi-devops"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into Bastion/App host"
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_port" {
  description = "Application port (e.g. 5000 or 80)"
  type        = number
  default     = 5000
}

variable "tags" {
  description = "Additional tags to apply to security groups"
  type        = map(string)
  default     = {}
}
