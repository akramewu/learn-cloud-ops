# Create a Launch Template
resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-template" 
  image_id      = var.ubuntu_ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "AutoScaledInstance"
    }
  }
}

# Create an Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity     = 2
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = [aws_subnet.public_subnet.id]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]

  tag {
    key                 = "Name"
    value               = "AutoScaledEC2"
    propagate_at_launch = true
  }
}

# Create Auto Scaling Policies - Scale Out
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

# Create Auto Scaling Policies - Scale In
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}