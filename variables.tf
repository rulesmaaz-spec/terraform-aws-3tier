# ---------- General ----------
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name (dev | staging | prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name (used as resource name prefix)"
  type        = string
  default     = "three-tier"
}

# ---------- Network ----------
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet CIDRs and AZs"
  type = list(object({
    cidr = string
    az   = string
  }))
  default = [
    { cidr = "10.0.1.0/24", az = "ap-south-1a" },
    { cidr = "10.0.3.0/24", az = "ap-south-1b" }
  ]
}

variable "private_subnets" {
  description = "Private subnet CIDRs and AZs"
  type = list(object({
    cidr = string
    az   = string
  }))
  default = [
    { cidr = "10.0.2.0/24", az = "ap-south-1a" },
    { cidr = "10.0.4.0/24", az = "ap-south-1b" }
  ]
}

# ---------- Security ----------
variable "key_name" {
  description = "Existing EC2 key pair name for SSH (required, no default)"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH. Set to YOUR_IP/32. Do NOT use 0.0.0.0/0."
  type        = string

  validation {
    condition     = var.ssh_allowed_cidr != "0.0.0.0/0"
    error_message = "Do not open SSH to the world. Use your IP/32."
  }
}

# ---------- Compute ----------
variable "instance_type" {
  description = "EC2 instance type for web/app tier"
  type        = string
  default     = "t3.micro"
}

variable "web_instance_count" {
  description = "Number of web servers"
  type        = number
  default     = 2

  validation {
    condition     = var.web_instance_count >= 1
    error_message = "At least one web instance is required."
  }
}

variable "app_instance_count" {
  description = "Number of application servers (Tier 2). Ignored unless enable_app_tier = true."
  type        = number
  default     = 1
}

# ---------- Storage ----------
variable "bucket_name_suffix" {
  description = "Globally unique suffix for S3 bucket name (e.g. yourname-2026)"
  type        = string
}

variable "s3_noncurrent_version_expiry_days" {
  description = "Days to retain non-current S3 object versions"
  type        = number
  default     = 30
}

# ---------- Optional tiers ----------
variable "enable_nat_gateway" {
  description = "Create per-AZ NAT Gateways so private subnets have egress (~$32/mo per AZ)"
  type        = bool
  default     = false
}

variable "enable_alb" {
  description = "Create an Application Load Balancer in front of the web tier (~$16/mo)"
  type        = bool
  default     = false
}

variable "enable_app_tier" {
  description = "Create Tier-2 application EC2 instances in private subnets (requires NAT for updates)"
  type        = bool
  default     = false
}

variable "enable_db_tier" {
  description = "Create Tier-3 RDS Postgres in private subnets (~$15-20/mo)"
  type        = bool
  default     = false
}

# ---------- RDS (only when enable_db_tier = true) ----------
variable "db_name" {
  description = "Initial Postgres database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Postgres admin username"
  type        = string
  default     = "appadmin"
  sensitive   = true
}

variable "db_password" {
  description = "Postgres admin password. Provide via TF_VAR_db_password env var or a secrets backend."
  type        = string
  sensitive   = true
  default     = ""

  validation {
    condition     = var.db_password == "" || length(var.db_password) >= 12
    error_message = "db_password must be at least 12 characters when provided."
  }
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}
