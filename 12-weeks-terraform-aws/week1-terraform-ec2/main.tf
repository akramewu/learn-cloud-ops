data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y nginx
    echo "Hello from Akramul's EC2 via Terraform 🚀" > /var/www/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOF

  tags = {
    Name    = "week1-ec2"
    Project = "learn-cloud-ops"
  }
}