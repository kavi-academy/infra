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
  description = "VPC ID where ALB and target groups will be created"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for app server (free tier eligible)"
  type        = string
  default     = "t3.micro"
}

variable "app_subnet_ids" {
  description = "List of Subnet IDs where Auto Scaling Group instances will be deployed across AZs"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of Public Subnet IDs for ALB and Bastion across AZs"
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security Group ID for App Server"
  type        = string
}

variable "alb_security_group_id" {
  description = "Security Group ID for Application Load Balancer"
  type        = string
}

variable "bastion_security_group_id" {
  description = "Security Group ID for Bastion host"
  type        = string
}

variable "asg_desired_capacity" {
  description = "Desired number of running EC2 instances in the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_min_size" {
  description = "Minimum number of instances in Auto Scaling Group"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of instances in Auto Scaling Group"
  type        = number
  default     = 4
}

variable "ecr_repository_url" {
  description = "Full URL of the Amazon ECR repository"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "app_port" {
  description = "Port the container runs on"
  type        = number
  default     = 5000
}

variable "image_tag" {
  description = "Docker image tag for the application container"
  type        = string
  default     = "latest"
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

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
