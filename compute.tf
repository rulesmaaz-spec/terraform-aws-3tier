# ============ Tier 1: Web servers (public subnets) ============
resource "aws_instance" "web" {
  for_each = local.web_instances

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[each.value.subnet_index].id
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = var.key_name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true

    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}-${each.key}-root"
    })
  }

  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    project_name      = var.project_name
    environment       = var.environment
    availability_zone = each.value.az
    instance_name     = each.key
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}"
    Role = "web"
    Tier = "1"
  })
}

# ============ Tier 2: App servers (private subnets, opt-in) ============
resource "aws_instance" "app" {
  for_each = var.enable_app_tier ? local.app_instances : {}

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private[each.value.subnet_index].id
  vpc_security_group_ids = [aws_security_group.app[0].id]
  key_name               = var.key_name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true

    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}-${each.key}-root"
    })
  }

  user_data = templatefile("${path.module}/templates/app_user_data.sh.tpl", {
    project_name  = var.project_name
    environment   = var.environment
    instance_name = each.key
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-${each.key}"
    Role = "app"
    Tier = "2"
  })
}

# ============ Optional ALB ============
resource "aws_lb" "web" {
  count              = var.enable_alb ? 1 : 0
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb[0].id]
  subnets            = aws_subnet.public[*].id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
  })
}

resource "aws_lb_target_group" "web" {
  count       = var.enable_alb ? 1 : 0
  name        = "${local.name_prefix}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-tg"
  })
}

resource "aws_lb_target_group_attachment" "web" {
  for_each = var.enable_alb ? aws_instance.web : {}

  target_group_arn = aws_lb_target_group.web[0].arn
  target_id        = each.value.id
  port             = 80
}

resource "aws_lb_listener" "http" {
  count             = var.enable_alb ? 1 : 0
  load_balancer_arn = aws_lb.web[0].arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web[0].arn
  }
}

# ============ Optional Tier 3: RDS Postgres ============
resource "aws_db_subnet_group" "main" {
  count      = var.enable_db_tier ? 1 : 0
  name       = "${local.name_prefix}-db-subnets"
  subnet_ids = aws_subnet.private[*].id

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db-subnets"
  })
}

resource "aws_db_instance" "main" {
  count = var.enable_db_tier ? 1 : 0

  identifier             = "${local.name_prefix}-db"
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = var.db_instance_class
  allocated_storage      = 20
  storage_encrypted      = true
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.main[0].name
  vpc_security_group_ids = [aws_security_group.db[0].id]
  skip_final_snapshot    = var.environment != "prod"
  deletion_protection    = var.environment == "prod"
  publicly_accessible    = false

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-db"
    Tier = "3"
  })
}
