############################################
# Variables for Compute Module (ASG + Launch Template)
############################################

# Project name for naming and tagging
variable "project" {
  description = "Project name used for tagging EC2 and ASG resources"
  type        = string
}

# VPC ID used for creating compute security groups
variable "vpc_id" {
  description = "VPC ID for launching EC2 instances and ASG resources"
  type        = string
}

# Private subnets where Auto Scaling Group will deploy EC2 instances
variable "private_subnets" {
  description = "List of private subnet IDs for EC2 Auto Scaling Group"
  type        = list(string)
}

############################################
# Input from Load Balancer Module
############################################

# ALB disabled for free tier — do not require these now
# variable "alb_sg_id" {
#   description = "Security Group ID of the ALB"
#   type        = string
# }

# variable "target_group_arn" {
#   description = "Target Group ARN"
#   type        = string
# }

############################################
# Launch Template Inputs
############################################

variable "ami_id" {
  description = "AMI ID for EC2 instances in the Auto Scaling Group"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for Launch Template"
  type        = string
}

############################################
# Auto Scaling Group Capacity
############################################

variable "asg_min" {
  description = "Minimum number of instances for the Auto Scaling Group"
  type        = number
}

variable "asg_max" {
  description = "Maximum number of instances for the Auto Scaling Group"
  type        = number
}

variable "asg_desired" {
  description = "Desired number of EC2 instances in the Auto Scaling Group"
  type        = number
}

# variable "alb_sg_id" {
#   description = "Security Group ID of ALB"
#   type        = string
# }

# variable "target_group_arn" {
#   description = "Target Group ARN"
#   type        = string
# }
