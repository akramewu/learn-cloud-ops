############################################
# Outputs for Load Balancer Module
############################################

# Security Group ID of the ALB
output "alb_sg_id" {
  description = "Security Group ID of the Application Load Balancer"
  value       = aws_security_group.alb_sg.id
}

# Target Group ARN for ASG
output "target_group_arn" {
  description = "ARN of the target group used by the ALB"
  value       = aws_lb_target_group.app_tg.arn
}

# ALB DNS Name (useful for testing)
output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.app_alb.dns_name
}
