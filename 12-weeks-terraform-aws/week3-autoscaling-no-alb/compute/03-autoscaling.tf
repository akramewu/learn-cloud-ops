############################################
# 3) Auto Scaling Group (EC2 in private subnets)
############################################
resource "aws_autoscaling_group" "app_asg" {
  name                      = "${var.project}-asg"
  desired_capacity          = var.asg_desired
  max_size                  = var.asg_max
  min_size                  = var.asg_min

  vpc_zone_identifier = var.private_subnets

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  health_check_type = "EC2"

  tag {
    key                 = "Name"
    value               = "${var.project}-instance"
    propagate_at_launch = true
  }
}
