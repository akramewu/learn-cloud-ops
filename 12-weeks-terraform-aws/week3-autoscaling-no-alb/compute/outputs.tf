############################################
# Outputs for Compute Module (ASG)
############################################

# Launch Template ID
output "launch_template_id" {
  description = "ID of the created launch template"
  value       = aws_launch_template.app_lt.id
}

# Auto Scaling Group Name
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app_asg.name
}
