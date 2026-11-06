variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "kavi-devops"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID for globally unique bucket naming"
  type        = string
}

variable "force_destroy" {
  description = "Allow destroying the bucket even if it contains objects"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags for S3 resources"
  type        = map(string)
  default     = {}
}
