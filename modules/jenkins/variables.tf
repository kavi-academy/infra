variable "project_name" {
  description = "Prefix for all resources"
  type        = string
  default     = "expenses-manager"
}

variable "environment" {
  description = "Deployment environment: dev | test | uat | prod"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "ID of the VPC where Jenkins will be placed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the Jenkins EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH access"
  type        = string
}

variable "public_key" {
  description = "Public key material for the key pair (if creating a new one)"
  type        = string
}
