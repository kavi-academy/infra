# Environment: dev

# Add your environment‑specific variables here (e.g., VPC CIDR, instance sizes).
# These values are passed to the modules in the infra layer.

variable "environment" {
  description = "Current environment name"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
