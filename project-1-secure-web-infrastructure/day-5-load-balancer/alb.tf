############################
# Target Group
# Purpose: EC2 instances এর একটা group - ALB এখানে traffic পাঠাবে
# Health Check: প্রতি 30 second এ check করবে EC2 healthy কিনা
############################
resource "aws_lb_target_group" "app_tg" {
  name        = "${var.project}-app-tg"
  port        = 80 # EC2 port 80 তে nginx চলছে
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance" # EC2 instance target করবে

  # Health Check - ALB check করবে EC2 কাজ করছে কিনা
  health_check {
    enabled             = true
    path                = "/" # কোন path check করবে
    protocol            = "HTTP"
    matcher             = "200" # HTTP 200 OK = healthy
    interval            = 30    # প্রতি 30 second check
    timeout             = 5     # 5 second wait
    healthy_threshold   = 2     # 2 বার success = healthy
    unhealthy_threshold = 2     # 2 বার fail = unhealthy
  }

  tags = {
    Name        = "${var.project}-app-tg"
    Environment = var.environment
    Project     = var.project
  }
}

############################
# Application Load Balancer
# Purpose: Internet থেকে traffic নিয়ে target group এ পাঠায়
# Multi-AZ: 2টা subnet লাগে high availability এর জন্য
############################
resource "aws_lb" "app_alb" {
  name               = "${var.project}-app-alb"
  internal           = false         # Internet-facing (public)
  load_balancer_type = "application" # HTTP/HTTPS layer load balancer
  security_groups    = [aws_security_group.alb_sg.id]

  # Minimum 2টা AZ এর subnet লাগে
  subnets = [
    aws_subnet.public_subnet.id,  # eu-west-2a
    aws_subnet.public_subnet_b.id # eu-west-2b
  ]

  tags = {
    Name        = "${var.project}-app-alb"
    Environment = var.environment
    Project     = var.project
  }
}

############################
# ALB Listener
# Purpose: Port 80 তে request শুনবে এবং target group এ forward করবে
############################
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  # Traffic কোথায় পাঠাবে
  default_action {
    type             = "forward"                      # Forward করো
    target_group_arn = aws_lb_target_group.app_tg.arn # এই target group এ
  }
}

############################
# Target Group Attachment
# Purpose: EC2 কে target group এ register করো
# Important: এইটা না দিলে target group empty থাকবে এবং 503 error আসবে
############################
resource "aws_lb_target_group_attachment" "app_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn # কোন target group
  target_id        = aws_instance.app_server.id     # কোন EC2
  port             = 80                             # কোন port
}