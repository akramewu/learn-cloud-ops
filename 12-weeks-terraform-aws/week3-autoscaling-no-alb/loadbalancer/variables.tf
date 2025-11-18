############################################
# Variables for Load Balancer Module (ALB)
############################################

# Project name used for tags and naming resources
variable "project" {
  description = "Project name used for naming ALB and related resources"
  type        = string
}

# VPC ID where ALB will be deployed
variable "vpc_id" {
  description = "VPC ID for the Application Load Balancer"
  type        = string
}

# Public subnets for ALB
variable "public_subnets" {
  description = "List of public subnet IDs where the ALB will be placed"
  type        = list(string)
}
