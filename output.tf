output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "web_instance_ids" {
  description = "Map: web instance name -> instance ID"
  value       = { for k, v in aws_instance.web : k => v.id }
}

output "web_public_ips" {
  description = "Map: web instance name -> public IP"
  value       = { for k, v in aws_instance.web : k => v.public_ip }
}

output "web_urls" {
  description = "Direct URLs to each web server (bypasses ALB)"
  value       = { for k, v in aws_instance.web : k => "http://${v.public_ip}" }
}

output "alb_dns_name" {
  description = "ALB DNS name (empty if enable_alb = false)"
  value       = var.enable_alb ? aws_lb.web[0].dns_name : ""
}

output "alb_url" {
  description = "Convenience URL for the ALB"
  value       = var.enable_alb ? "http://${aws_lb.web[0].dns_name}" : ""
}

output "app_instance_ids" {
  description = "Map: app instance name -> instance ID (empty if enable_app_tier = false)"
  value       = { for k, v in aws_instance.app : k => v.id }
}

output "db_endpoint" {
  description = "RDS endpoint (empty if enable_db_tier = false)"
  value       = var.enable_db_tier ? aws_db_instance.main[0].endpoint : ""
  sensitive   = true
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.assets.bucket
}

output "s3_bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.assets.arn
}

output "deployment_summary" {
  description = "Human-readable summary"
  value = {
    environment    = var.environment
    region         = var.aws_region
    web_count      = var.web_instance_count
    app_count      = var.enable_app_tier ? var.app_instance_count : 0
    db_enabled     = var.enable_db_tier
    alb_enabled    = var.enable_alb
    nat_enabled    = var.enable_nat_gateway
    web_urls       = { for k, v in aws_instance.web : k => "http://${v.public_ip}" }
    alb_url        = var.enable_alb ? "http://${aws_lb.web[0].dns_name}" : null
  }
}

