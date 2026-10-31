# Terraform module to provision a Jenkins server on AWS (free‑tier compatible)

resource "aws_key_pair" "jenkins" {
  key_name   = var.key_name
  public_key = var.public_key
}

# Detect caller's public IP for SSH access (optional security)
data "http" "my_ip" {
  url = "http://checkip.amazonaws.com/"
}

resource "aws_security_group" "jenkins_sg" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Allow HTTP (8080) and SSH (22) from the creator's IP"
  vpc_id      = var.vpc_id

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [trimspace(data.http.my_ip.body) + "/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-jenkins-sg"
  }
}

resource "aws_iam_role" "jenkins_role" {
  name = "${var.project_name}-jenkins-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_read_write" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "${var.project_name}-jenkins-profile"
  role = aws_iam_role.jenkins_role.name
}

resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.jenkins_profile.name
  key_name                    = aws_key_pair.jenkins.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    amazon-linux-extras install java-openjdk11 -y
    wget -O /tmp/jenkins.war https://get.jenkins.io/war-stable/latest/jenkins.war
    nohup java -jar /tmp/jenkins.war --httpPort=8080 &
  EOF

  tags = {
    Name        = "${var.project_name}-jenkins"
    Environment = var.environment
  }
}

# Output useful connection info
output "jenkins_public_ip" {
  description = "Public IP of the Jenkins EC2 instance"
  value       = aws_instance.jenkins.public_ip
}

output "jenkins_url" {
  description = "URL to access Jenkins UI"
  value       = "http://${aws_instance.jenkins.public_ip}:8080"
}
