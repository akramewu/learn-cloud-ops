#Resource: aws_autoscaling_policy
#Name: scale-out

#Policy type: "TargetTrackingScaling"
#Target tracking configuration:

#Predefined metric: ASGAverageCPUUtilization
#Target value: 70.0 (CPU 70% হলে scale out)
resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "${var.project}-scale-out-policy"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

#Resource: aws_autoscaling_policy
#Name: scale-in

#Simple scaling
#Scaling adjustment: -1 (1টা instance remove করো)
#Adjustment type: "ChangeInCapacity"
#Cooldown: 300
resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "${var.project}-scale-in-policy"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "SimpleScaling"

  adjustment_type    = "ChangeInCapacity"
  scaling_adjustment = -1
  cooldown           = 300
}

#Resource: aws_cloudwatch_metric_alarm
#Alarm name: ${var.project}-high-cpu

#Metric name: "CPUUtilization"
#Namespace: "AWS/EC2"
#Statistic: "Average"
#Period: 300 (5 minutes)
#Evaluation periods: 2 (2 consecutive periods)
#Threshold: 70 (CPU > 70%)
#Comparison operator: "GreaterThanThreshold"
#Alarm actions: [scale_out_policy.arn]
#Dimensions: ASG name
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "${var.project}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70.0

  alarm_actions = [aws_autoscaling_policy.scale_out_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}

#Low CPU Alarm (Scale IN trigger):
#Resource: aws_cloudwatch_metric_alarm
#Alarm name: ${var.project}-low-cpu

#Threshold: 30 (CPU < 30%)
#Comparison operator: "LessThanThreshold"
#Alarm actions: [scale_in_policy.arn]
resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name          = "${var.project}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 30.0

  alarm_actions = [aws_autoscaling_policy.scale_in_policy.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}