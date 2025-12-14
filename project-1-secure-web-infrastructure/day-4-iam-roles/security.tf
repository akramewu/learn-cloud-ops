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
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
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