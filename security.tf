# ---------- Tier 1: Web SG ----------
resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web-sg"
  description = "Tier 1 - SSH from admin, HTTP from anywhere"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from admin CIDR only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-web-sg"
    Tier = "1"
  })
}

# ---------- Tier 2: App SG (only created when app tier is enabled) ----------
resource "aws_security_group" "app" {
  count       = var.enable_app_tier ? 1 : 0
  name        = "${local.name_prefix}-app-sg"
  description = "Tier 2 - only accepts traffic from web SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "App port from web tier only"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    description = "All outbound (needed for NAT egress to updates, DB)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-app-sg"
    Tier = "2"
  })
}

# ---------- Tier 3: DB SG (only created when db tier is enabled) ----------
resource "aws_security_group" "db" {
  count       = var.enable_db_tier ? 1 : 0
  name        = "${local.name_prefix}-db-sg"
  description = "Tier 3 - only accepts Postgres from app SG"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Postgres from app tier only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app[0].id]
  }

  egress {
    description = "No outbound required"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-sg"
    Tier = "3"
  })
}

# ---------- Optional ALB SG ----------
resource "aws_security_group" "alb" {
  count       = var.enable_alb ? 1 : 0
  name        = "${local.name_prefix}-alb-sg"
  description = "ALB - HTTP from anywhere, egress to web tier"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound (to web instances)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb-sg"
  })
}
