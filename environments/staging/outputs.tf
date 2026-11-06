output "vpc_id" {
  description = "VPC ID of the staging environment"
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

output "app_server_public_ip" {
  description = "Public IP of the application server"
  value       = module.ec2.app_instance_public_ip
}

output "app_server_private_ip" {
  description = "Private IP of the application server"
  value       = module.ec2.app_instance_private_ip
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
