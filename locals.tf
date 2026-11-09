locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = "REPLACE-WITH-YOUR-NAME"
  }

  s3_bucket_name = "${var.project_name}-assets-${var.bucket_name_suffix}"

  # Stable, non-index-based keys so removing one instance does not recreate the rest.
  web_instances = {
    for i in range(var.web_instance_count) :
    "web-${i + 1}" => {
      subnet_index = i % length(var.public_subnets)
      az           = var.public_subnets[i % length(var.public_subnets)].az
    }
  }

  app_instances = {
    for i in range(var.app_instance_count) :
    "app-${i + 1}" => {
      subnet_index = i % length(var.private_subnets)
      az           = var.private_subnets[i % length(var.private_subnets)].az
    }
  }
}

