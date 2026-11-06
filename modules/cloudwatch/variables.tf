variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "kavi-devops"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "app_instance_id" {
  description = "EC2 instance ID to monitor with CPU alarm"
  type        = string
}

variable "retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the specified log group"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags for CloudWatch resources"
  type        = map(string)
  default     = {}
}
