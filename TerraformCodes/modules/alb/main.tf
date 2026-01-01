# ALB creation
resource "aws_lb" "ecs_alb" {
  name               = "${var.name_prefix}-alb"
  load_balancer_type = "application"
  internal           = false
  ip_address_type    = "ipv4"
  security_groups    = [var.alb_sg_id]

  subnets = [
    var.public_subnet_01_id,
    var.public_subnet_02_id
  ]

  tags = {
    Name        = "${var.name_prefix}-alb"
    Environment = "dev"
  }
}

# Target Groups
resource "aws_lb_target_group" "user_tg" {
  name        = "${var.name_prefix}-user-tg"
  target_type = "ip"
  port        = 3001
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.name_prefix}-user-tg"
  }
}

resource "aws_lb_target_group" "product_tg" {
  name        = "${var.name_prefix}-product-tg"
  target_type = "ip"
  port        = 3002
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.name_prefix}-product-tg"
  }
}

# Listeners and Listener Rules
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.user_tg.arn
  }
}

resource "aws_lb_listener_rule" "users_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 10

  condition {
    path_pattern {
      values = ["/users*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.user_tg.arn
  }
}

resource "aws_lb_listener_rule" "products_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 20

  condition {
    path_pattern {
      values = ["/products*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.product_tg.arn
  }
}