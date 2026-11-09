terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "three_tier" {
  source = "../../"

  aws_region           = var.aws_region
  environment          = var.environment
  project_name         = var.project_name
  key_name             = var.key_name
  ssh_allowed_cidr     = var.ssh_allowed_cidr
  bucket_name_suffix   = var.bucket_name_suffix
  web_instance_count   = var.web_instance_count
  instance_type        = var.instance_type
  enable_nat_gateway   = var.enable_nat_gateway
  enable_alb           = var.enable_alb
  enable_app_tier      = var.enable_app_tier
  enable_db_tier       = var.enable_db_tier
  db_username          = var.db_username
  db_password          = var.db_password
}
