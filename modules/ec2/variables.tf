variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "kavi-devops"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for app server (free tier eligible)"
  type        = string
  default     = "t3.micro"
}

variable "app_subnet_id" {
  description = "Subnet ID where App Server will be deployed"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for Bastion server"
  type        = string
}

variable "app_security_group_id" {
  description = "Security Group ID for App Server"
  type        = string
}

variable "bastion_security_group_id" {
  description = "Security Group ID for Bastion host"
  type        = string
}

variable "key_name" {
  description = "Existing EC2 Key Pair name for SSH access (optional)"
  type        = string
  default     = ""
}

variable "enable_bastion" {
  description = "Whether to create a Bastion jump host"
  type        = bool
  default     = false
}

variable "image_tag" {
  description = "Docker image tag for the application container"
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
