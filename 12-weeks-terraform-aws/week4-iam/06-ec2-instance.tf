############################################
# EC2 Instance with IAM Role
# Real-world use: Application server that reads from S3
############################################

# Get Default VPC
data "aws_vpc" "default" {
  default = true
}

# Get Default Subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group - Allow outbound traffic for SSM and S3
resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for EC2 instance"
  vpc_id      = data.aws_vpc.default.id
  
  # Outbound - Allow all (for SSM and S3 access)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = {
    Name    = "${var.project_name}-ec2-sg"
    Project = var.project_name
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  # CRITICAL: Attach IAM Instance Profile
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  
  # Use first default subnet
  subnet_id                   = sort(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  
  # User Data - Install AWS CLI and SSM Agent
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e
    
    # Update system
    apt-get update -y
    
    # Install AWS CLI
    apt-get install -y awscli
    
    # SSM Agent is pre-installed on Ubuntu 22.04
    systemctl enable snap.amazon-ssm-agent.amazon-ssm-agent
    systemctl start snap.amazon-ssm-agent.amazon-ssm-agent
    
    # Create test message
    echo "EC2 instance ready with IAM role!" > /home/ubuntu/status.txt
    
    # Log for debugging
    echo "Setup completed at $(date)" >> /var/log/user-data.log
  EOF
  )
  
  tags = {
    Name    = "${var.project_name}-app-server"
    Project = var.project_name
  }
}