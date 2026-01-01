# # Security Group
# resource "aws_security_group" "ecs-tasks-sg" {
#   name        = "${var.name_prefix}-tasks-sg"
#   description = "Allow 3001 and 3002 inbound traffic from alb sg"
#   vpc_id      = var.vpc_id

#   ingress {
#     description = "For user service"
#     from_port   = 3001
#     to_port     = 3001
#     protocol    = "tcp"
#     security_groups = [aws_security_group.ecs-alb-sg.id]
#   }

#   ingress {
#     description = "For product service"
#     from_port   = 3002
#     to_port     = 3002
#     protocol    = "tcp"
#     security_groups = [aws_security_group.ecs-alb-sg.id]
#   }

#   egress {
#     description = "Allow all outbound"
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name        = "${var.name_prefix}-tasks-sg"
#     Environment = "dev"
#     Owner       = var.name_prefix
#   }
# }

# resource "aws_security_group" "ecs-alb-sg" {
#   name        = "${var.name_prefix}-alb-sg"
#   description = "Allow inbound traffic from anywhere"
#   vpc_id      = var.vpc_id

#   ingress {
#     description = "HTTP access from anywhere"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     description = "Allow user service outbound to tasks SG"
#     from_port   = 3001
#     to_port     = 3001
#     protocol    = "tcp"
#     security_groups = [aws_security_group.ecs-tasks-sg.id]
#   }

#   egress {
#     description = "Allow product service outbound to tasks SG"
#     from_port   = 3002
#     to_port     = 3002
#     protocol    = "tcp"
#     security_groups = [aws_security_group.ecs-tasks-sg.id]
#   }

#   tags = {
#     Name        = "${var.name_prefix}-alb-sg"
#     Environment = "dev"
#     Owner       = var.name_prefix
#   }
# }

resource "aws_security_group" "ecs_alb_sg" {
  name        = "${var.name_prefix}-alb-sg"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.name_prefix}-alb-sg"
    Environment = "dev"
    Owner       = var.name_prefix
  }
}

resource "aws_security_group" "ecs_tasks_sg" {
  name        = "${var.name_prefix}-tasks-sg"
  description = "ECS tasks security group"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.name_prefix}-tasks-sg"
    Environment = "dev"
    Owner       = var.name_prefix
  }
}

resource "aws_security_group_rule" "tasks_user_service" {
  type                     = "ingress"
  from_port                = 3001
  to_port                  = 3001
  protocol                 = "tcp"
  security_group_id         = aws_security_group.ecs_tasks_sg.id
  source_security_group_id  = aws_security_group.ecs_alb_sg.id
}

resource "aws_security_group_rule" "tasks_product_service" {
  type                     = "ingress"
  from_port                = 3002
  to_port                  = 3002
  protocol                 = "tcp"
  security_group_id         = aws_security_group.ecs_tasks_sg.id
  source_security_group_id  = aws_security_group.ecs_alb_sg.id
}

resource "aws_security_group_rule" "alb_http_in" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_alb_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTP from internet"
}

resource "aws_security_group_rule" "tasks_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs_tasks_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_egress_user_service" {
  type                     = "egress"
  from_port                = 3001
  to_port                  = 3001
  protocol                 = "tcp"
  security_group_id         = aws_security_group.ecs_alb_sg.id
  source_security_group_id  = aws_security_group.ecs_tasks_sg.id
}

resource "aws_security_group_rule" "alb_egress_product_service" {
  type                     = "egress"
  from_port                = 3002
  to_port                  = 3002
  protocol                 = "tcp"
  security_group_id         = aws_security_group.ecs_alb_sg.id
  source_security_group_id  = aws_security_group.ecs_tasks_sg.id
}