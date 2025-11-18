############################################
# Root Module Variables (Top Level Settings)
############################################

# Project name (used for naming and tagging)
variable "project" {
  description = "Project name used for naming resources"
  type        = string
}


############################################
# Networking Variables (passed to networking module)
############################################

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_a" {
  description = "CIDR block for public subnet A"
  type        = string
}

variable "public_subnet_b" {
  description = "CIDR block for public subnet B"
  type        = string
}

variable "private_subnet_a" {
  description = "CIDR block for private subnet A"
  type        = string
}

variable "private_subnet_b" {
  description = "CIDR block for private subnet B"
  type        = string
}

variable "availability_zone_a" {
  description = "Availability Zone for subnet A"
  type        = string
}

variable "availability_zone_b" {
  description = "Availability Zone for subnet B"
  type        = string
}


############################################
# Compute / EC2 Launch Template Variables
############################################

variable "ami_id" {
  description = "AMI ID for EC2 instances in the ASG"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2"
  type        = string
}


############################################
# Auto Scaling Group Capacity Variables
############################################

variable "asg_min" {
  description = "Minimum number of EC2 instances"
  type        = number
}

variable "asg_max" {
  description = "Maximum number of EC2 instances"
  type        = number
}

variable "asg_desired" {
  description = "Desired number of EC2 instances"
  type        = number
}
