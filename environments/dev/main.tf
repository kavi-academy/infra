# ─────────────────────────────────────────────
# Dev Environment Infrastructure Root
# ─────────────────────────────────────────────

module "ecr" {
  source = "../../modules/ecr"

  repository_name = var.ecr_repo_name
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security_group" {
  source = "../../modules/security_group"

  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
  app_port         = 5000
}

module "ec2" {
  source = "../../modules/ec2"

  project_name              = var.project_name
  environment               = var.environment
  vpc_id                    = module.vpc.vpc_id
  instance_type             = var.instance_type
  app_subnet_ids            = module.vpc.public_subnet_ids
  public_subnet_ids         = module.vpc.public_subnet_ids
  app_security_group_id     = module.security_group.app_security_group_id
  alb_security_group_id     = module.security_group.alb_security_group_id
  bastion_security_group_id = module.security_group.bastion_security_group_id
  key_name                  = var.key_name
  enable_bastion            = var.enable_bastion
  asg_desired_capacity      = var.asg_desired_capacity
  asg_min_size              = var.asg_min_size
  asg_max_size              = var.asg_max_size
  ecr_repository_url        = module.ecr.repository_url
  aws_region                = var.aws_region
  image_tag                 = var.image_tag
}

module "s3" {
  source = "../../modules/s3"

  project_name   = var.project_name
  environment    = var.environment
  aws_account_id = var.aws_account_id
  force_destroy  = true
}

module "rds" {
  source = "../../modules/rds"

  project_name          = var.project_name
  environment           = var.environment
  enable_rds            = var.enable_rds
  db_instance_class     = var.db_instance_class
  allocated_storage     = var.allocated_storage
  private_subnet_ids    = module.vpc.private_subnet_ids
  rds_security_group_id = module.security_group.rds_security_group_id
}

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  project_name = var.project_name
  environment  = var.environment
  asg_name     = module.ec2.asg_name
}
