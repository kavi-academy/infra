output "app_instance_id" {
  description = "ID of the Application EC2 instance"
  value       = aws_instance.app.id
}

output "app_instance_public_ip" {
  description = "Public IP of the Application EC2 instance"
  value       = aws_instance.app.public_ip
}

output "app_instance_private_ip" {
  description = "Private IP of the Application EC2 instance"
  value       = aws_instance.app.private_ip
}

output "bastion_instance_public_ip" {
  description = "Public IP of the Bastion instance (if enabled)"
  value       = var.enable_bastion ? aws_instance.bastion[0].public_ip : null
}

output "bastion_eip" {
  description = "Elastic IP allocated for Bastion (if enabled)"
  value       = var.enable_bastion ? aws_eip.bastion[0].public_ip : null
}

output "iam_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = aws_iam_role.app.arn
}
