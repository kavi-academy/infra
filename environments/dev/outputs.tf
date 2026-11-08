output "vpc_id" {
  description = "VPC ID of the dev environment"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "alb_dns_name" {
  description = "Public URL of Application Load Balancer (access your application here)"
  value       = "http://${module.ec2.alb_dns_name}"
}

output "ecr_repository_url" {
  description = "ECR Repository URL for pushing Docker images"
  value       = module.ecr.repository_url
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.ec2.asg_name
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion server"
  value       = module.ec2.bastion_instance_public_ip
}

output "artifacts_bucket_name" {
  description = "Name of the environment S3 artifacts bucket"
  value       = module.s3.bucket_name
}

output "database_endpoint" {
  description = "Database connection endpoint (if enabled)"
  value       = module.rds.db_endpoint
}

output "cloudwatch_log_group" {
  description = "Name of the application CloudWatch log group"
  value       = module.cloudwatch.log_group_name
}
