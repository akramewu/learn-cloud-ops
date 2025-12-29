# Resource: aws_launch_template 
# কী define করতে হবে:

#Name: ${var.project}-launch-template
#AMI ID: তোমার Ubuntu AMI (same as Day 3-5)
#Instance type: t2.micro
#Key name: তোমার SSH key
#Security groups: private_sg (existing)
#IAM instance profile: ec2_instance_profile (existing from Day 4)
#User data: nginx install script (same as Day 5)
#Important:

#network_interfaces block লাগবে না launch template এ
#Subnet ASG এ define করবে
resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "${var.project}-launch-template-" # লঞ্চ টেমপ্লেটের নামের প্রিফিক্স
  image_id      = var.ami_id                        # কোন AMI থেকে ইন্সট্যান্স তৈরি হবে?
  instance_type = "t2.micro"                        # ইন্সট্যান্সের টাইপ কী হবে?
  key_name      = var.ssh_key_name                  # SSH কী এর নাম

  # Security Group যুক্ত করো
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  # IAM Instance Profile যুক্ত করো or EC2 কে ব্যাজ দাও
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  user_data = base64encode(<<EOF
#!/bin/bash
# Update system
apt update -y
# Install nginx
apt install -y nginx
# Start and enable nginx
systemctl start nginx
systemctl enable nginx
# Create custom index page
echo "<h1>Hello from Auto Scaling Group Server!</h1>" > /var/www/html
echo "<p>Hostname: $(hostname)</p>" >> /var/www/html/index.html
echo "<p>Private IP: $(hostname -I)</p>" >> /var/www/html
echo "<p>OS: Ubuntu</p>" >> /var/www/html/index.html
EOF
  )
  tags = {
    Name    = "${var.project}-launch-template"
    Project = var.project
  }

}

#Resource: aws_autoscaling_group
#কী define করতে হবে:

#Name: ${var.project}-asg
#Launch template reference (উপরের launch template)
#Min size: 1 (minimum 1 instance সবসময়)
#Max size: 3 (maximum 3 instances)
#Desired capacity: 2 (normally 2 instances চলবে)
#VPC zone identifier: [private_subnet_a, private_subnet_b] (দুই AZ তে)
#Target group ARNs: [app_tg] (Day 5 এর target group)
#Health check type: "ELB" (ALB health check use করবে)
#Health check grace period: 300 (5 minutes wait new instance এর জন্য)
resource "aws_autoscaling_group" "app_asg" {
  name             = "${var.project}-asg" # ASG এর নাম
  max_size         = 3                    # সর্বোচ্চ ইন্সট্যান্স সংখ্যা
  min_size         = 1                    # সর্বনিম্ন ইন্সট্যান্স সংখ্যা
  desired_capacity = 2                    # প্রাথমিক ইন্সট্যান্স সংখ্যা
  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id] # কোন সাবনেটে ইন্সট্যান্স তৈরি হবে?

  target_group_arns = [aws_lb_target_group.app_tg.arn] # Target group ARNs

  health_check_type         = "ELB" # ELB health check ব্যবহার করো
  health_check_grace_period = 300   # ৫ মিনিট grace period

  tag {
    key                 = "Name"
    value               = "${var.project}-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project
    propagate_at_launch = true
  }

}


