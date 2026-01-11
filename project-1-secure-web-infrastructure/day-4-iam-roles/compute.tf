############################
# Bastion EC2 Instance
############################
resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]

  tags = {
    Name        = "${var.project}-bastion-host"
    Environment = var.environment
    Project     = var.project
  }
}

############################
# Private Web Server EC2 Instance
############################
resource "aws_instance" "app_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.private_subnet_a.id
  associate_public_ip_address = false
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name

    user_data = <<-EOF
    #!/bin/bash
    # Update system
    apt update -y
    
    # Install nginx
    apt install -y nginx
    
    # Install Docker
    apt install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ubuntu
    
    # Install AWS CLI
    apt install -y awscli
    
    # Start and enable nginx
    systemctl start nginx
    systemctl enable nginx
    
    # Create custom index page
    echo "<h1>Hello from Private Server!</h1>" > /var/www/html/index.html
    echo "<p>Hostname: $(hostname)</p>" >> /var/www/html/index.html
    echo "<p>Private IP: $(hostname -I)</p>" >> /var/www/html/index.html
    echo "<p>OS: Ubuntu</p>" >> /var/www/html/index.html
    echo "<p>Docker: Installed</p>" >> /var/www/html/index.html
    echo "<p>AWS CLI: Installed</p>" >> /var/www/html/index.html
  EOF

  tags = {
    Name        = "${var.project}-private-web-server"
    Environment = var.environment
    Project     = var.project
  }
}