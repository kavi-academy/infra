data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

# ─────────────────────────────────────────────
# IAM Role & Instance Profile for EC2
# ─────────────────────────────────────────────
resource "aws_iam_role" "app" {
  name = "${local.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "app" {
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.app.name

  tags = local.common_tags
}

# ─────────────────────────────────────────────
# Application Load Balancer (ALB)
# ─────────────────────────────────────────────
resource "aws_lb" "app" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
  })
}

resource "aws_lb_target_group" "app" {
  name        = "${local.name_prefix}-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/api/expense"
    port                = tostring(var.app_port)
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200,404,405"
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-tg"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ─────────────────────────────────────────────
# Launch Template for Auto Scaling Group
# ─────────────────────────────────────────────
resource "aws_launch_template" "app" {
  name_prefix   = "${local.name_prefix}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  iam_instance_profile {
    arn = aws_iam_instance_profile.app.arn
  }

  vpc_security_group_ids = [var.app_security_group_id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 2
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    exec > /var/log/user-data.log 2>&1
    set -e

    # Add swap space (2 GB) to prevent OOM
    dd if=/dev/zero of=/swapfile bs=128M count=16
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile swap swap defaults 0 0' >> /etc/fstab

    # Install Docker & AWS CLI
    dnf update -y
    dnf install -y docker
    systemctl enable --now docker
    usermod -aG docker ec2-user

    # Setup Deployment and Startup Script
    cat <<'APP_SCRIPT' > /usr/local/bin/run-app.sh
    #!/bin/bash
    set -e
    ECR_URL="${var.ecr_repository_url}"
    TAG="${var.image_tag}"
    PORT="${var.app_port}"
    REGION="${var.aws_region}"

    if [ -n "$ECR_URL" ]; then
      echo "Authenticating with ECR..."
      aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_URL || true
      if docker pull "$ECR_URL:$TAG"; then
        docker stop app || true
        docker rm app || true
        docker run -d --name app --restart unless-stopped -p $PORT:5000 -e PORT=5000 "$ECR_URL:$TAG"
        echo "Successfully deployed $ECR_URL:$TAG"
        exit 0
      fi
    fi

    # Fallback placeholder webserver until image is pushed to ECR
    echo "Starting bootstrap placeholder on port $PORT..."
    docker stop app || true
    docker rm app || true
    docker run -d --name app --restart unless-stopped -p $PORT:5000 -e PORT=5000 python:3.11-slim python -c '
from http.server import HTTPServer, BaseHTTPRequestHandler
class H(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header("Content-type", "application/json")
        self.end_headers()
        self.wfile.write(b"{\"status\":\"ready\",\"message\":\"Auto Scaling instances active. Waiting for CI/CD container push.\",\"environment\":\"${var.environment}\"}")
HTTPServer(("", 5000), H).serve_forever()'
    APP_SCRIPT

    chmod +x /usr/local/bin/run-app.sh
    /usr/local/bin/run-app.sh
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}-asg-instance"
      Role = "application"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ─────────────────────────────────────────────
# Auto Scaling Group (2 Instances Desired)
# ─────────────────────────────────────────────
resource "aws_autoscaling_group" "app" {
  name_prefix               = "${local.name_prefix}-asg-"
  desired_capacity          = var.asg_desired_capacity
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  vpc_zone_identifier       = var.app_subnet_ids
  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "terraform"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ─────────────────────────────────────────────
# Bastion Host (Optional)
# ─────────────────────────────────────────────
resource "aws_instance" "bastion" {
  count                       = var.enable_bastion ? 1 : 0
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [var.bastion_security_group_id]
  associate_public_ip_address = true
  key_name                    = var.key_name != "" ? var.key_name : null

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-bastion"
    Role = "bastion"
  })
}

resource "aws_eip" "bastion" {
  count    = var.enable_bastion ? 1 : 0
  domain   = "vpc"
  instance = aws_instance.bastion[0].id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-bastion-eip"
  })
}
