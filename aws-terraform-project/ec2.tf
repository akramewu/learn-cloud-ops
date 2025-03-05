# Add Public Key for SSH
resource "aws_key_pair" "my_key" {
  key_name   = var.key_name
  public_key = file("akramul_test_key_pair.pub")
}

# Create EC2 Instance for Web Server
resource "aws_instance" "web_server" {
  ami                    = var.ubuntu_ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.my_key.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "WebServer"
  }
}

# Assign an Elastic IP to Web Server
resource "aws_eip" "web_eip" {
  instance = aws_instance.web_server.id
  domain   = "vpc"

  tags = {
    Name = "WebEIP"
  }
}