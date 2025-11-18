############################################
# 2) Launch Template (defines EC2 settings)
############################################
resource "aws_launch_template" "app_lt" {
  name = "${var.project}-launch-template"

  image_id      = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [
    aws_security_group.asg_sg.id
  ]

  user_data = base64encode(<<EOF
#!/bin/bash
sudo apt update -y
sudo apt install -y nginx
echo "<h1>Deployed via Terraform ASG</h1>" > /var/www/html/index.html
EOF
  )

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project}-lt"
  }
}
