output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.app.arn
}

output "target_group_arn" {
  description = "ARN of the ALB Target Group"
  value       = aws_lb_target_group.app.arn
}

output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.arn
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
