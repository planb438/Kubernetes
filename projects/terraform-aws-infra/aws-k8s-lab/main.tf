terraform {
  required_version = ">= 1.0.0"
  
  backend "s3" {
    bucket         = "your-terraform-state-bucket-name"
    key            = "3-node-cluster/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Create S3 bucket for Terraform state (uncomment if bucket doesn't exist)
/*
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-${random_id.bucket_suffix.hex}"
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}
*/

module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  aws_region          = var.aws_region
  project_name        = var.project_name
}

module "iam" {
  source = "./modules/iam"
  
  project_name = var.project_name
}

module "ec2_cluster" {
  source = "./modules/ec2"
  
  project_name        = var.project_name
  instance_count      = 3
  instance_type       = var.instance_type
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  key_name           = var.key_name
  iam_instance_profile = module.iam.instance_profile_name
  
  depends_on = [module.vpc, module.iam]
}