############################
# ALB Security Group
# Purpose: ALB এর জন্য traffic rules - internet থেকে port 80 allow
############################
resource "aws_security_group" "alb_sg" {
  name        = "${var.project}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name        = "${var.project}-alb-sg"
    Environment = var.environment
    Project     = var.project
  }

  # Inbound: Port 80 from anywhere (internet users)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Anyone can access ALB
    description = "HTTP from internet"
  }

  # Outbound: ALB থেকে target group এ traffic পাঠানোর জন্য
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

############################
# Security Group for Bastion Host
############################
resource "aws_security_group" "bastion_sg" {
  name        = "${var.project}-bastion-sg"
  description = "Security group for Bastion Host"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name    = "${var.project}-bastion-sg"
    Project = var.project
  }

  # Inbound - Allow SSH from anywhere (for demo purposes; restrict in production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
    description = "SSH from my IP"
  }

  # Outbound - Allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}


############################
# Security Group for Private Application Server
############################
resource "aws_security_group" "private_sg" {
  name        = "${var.project}-private-sg"
  description = "Security group for Private Application Server"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name    = "${var.project}-private-sg"
    Project = var.project
  }


  # Inbound - Allow SSH from Bastion Host only
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
    description     = "SSH from Bastion Host"
  }

  # Inbound - Allow HTTP from anywhere 
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    #cidr_blocks = ["0.0.0.0/0"] # ← পরিবর্তন করলাম (anywhere)
    security_groups = [aws_security_group.alb_sg.id] # ← শুধু ALB থেকে access দিবো
    description     = "HTTP from ALB only"
  }

  # Outbound - Allow all traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

}