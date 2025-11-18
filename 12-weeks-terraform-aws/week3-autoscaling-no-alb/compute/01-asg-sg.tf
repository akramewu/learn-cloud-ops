############################################
# ASG Security Group (NO ALB MODE)
############################################
resource "aws_security_group" "asg_sg" {
  name        = "${var.project}-asg-sg"
  description = "Security group for ASG instances"
  vpc_id      = var.vpc_id

  # Allow HTTP from inside VPC (private & safe)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Allow all outbound (NAT handles Internet)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}-asg-sg"
  }
}
