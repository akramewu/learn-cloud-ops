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
  
  # Wait for internet connectivity
  echo "Waiting for internet connectivity..."
  CONNECTED=false
  for i in {1..30}; do
    if curl -s --max-time 5 http://google.com > /dev/null 2>&1; then
      echo "Internet connected!"
      CONNECTED=true
      break
    fi
    echo "Attempt $i: No internet yet, waiting..."
    sleep 10
  done
  
  # Fail-safe exit
  if [ "$CONNECTED" != "true" ]; then
    echo "ERROR: Internet not available after 5 minutes. Exiting."
    exit 1
  fi
  
  # Now install packages
  apt update -y
  apt install -y nginx docker.io unzip curl
  
  systemctl start docker
  systemctl enable docker
  usermod -aG docker ubuntu
  
  # Install AWS CLI v2
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
  unzip /tmp/awscliv2.zip -d /tmp
  /tmp/aws/install
  rm -rf /tmp/aws /tmp/awscliv2.zip
  
  systemctl start nginx
  systemctl enable nginx
  
  echo "<h1>Hello from Private Server!</h1>" > /var/www/html/index.html
  echo "<p>Docker & AWS CLI: Installed</p>" >> /var/www/html/index.html
EOF

  tags = {
    Name        = "${var.project}-private-web-server"
    Environment = var.environment
    Project     = var.project
  }
}