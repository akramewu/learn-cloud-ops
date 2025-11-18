############################################
# 2) Application Load Balancer (public)
############################################
resource "aws_lb" "app_alb" {
  name               = "${var.project}-alb"
  load_balancer_type = "application"

  # ALB sits in public subnets
  subnets = var.public_subnets

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  tags = {
    Name = "${var.project}-alb"
  }
}
