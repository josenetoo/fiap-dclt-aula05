# ============================================
# TERRAFORM CONFIGURATION
# ============================================
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "fiap-terraform-state-modules"
    key     = "modules/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

# ============================================
# PROVIDER
# ============================================
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "modules"
      Project     = "fiap-cicd"
      ManagedBy   = "terraform"
      Video       = "5.3"
    }
  }
}

# ============================================
# VPC MODULE
# ============================================
module "vpc" {
  source = "../../modules/vpc"

  name                 = "fiap-modules"
  vpc_cidr             = "10.2.0.0/16"
  public_subnet_count  = 2
  private_subnet_count = 0
  enable_nat_gateway   = false

  tags = {
    Environment = "modules"
    Project     = "fiap-cicd"
  }
}

# ============================================
# SECURITY GROUP MODULE
# ============================================
module "web_sg" {
  source = "../../modules/security-group"

  name        = "fiap-modules-web"
  description = "Security group for web servers"
  vpc_id      = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS"
    }
  ]

  tags = {
    Environment = "modules"
    Project     = "fiap-cicd"
  }
}

# ============================================
# S3 MODULE
# ============================================
module "artifacts" {
  source = "../../modules/s3"

  bucket_name       = "fiap-modules-artifacts"
  use_random_suffix = true

  tags = {
    Environment = "modules"
    Project     = "fiap-cicd"
  }
}
