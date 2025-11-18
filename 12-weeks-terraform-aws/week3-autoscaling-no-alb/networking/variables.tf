############################################
# Variables for Networking Module (VPC + Subnets + Routes)
############################################

# Project name (used for naming and tagging)
variable "project" {
  description = "Project name used for naming VPC and related networking resources"
  type        = string
}

# VPC CIDR block
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# Public subnet CIDRs
variable "public_subnet_a" {
  description = "CIDR block for public subnet in AZ A"
  type        = string
}

variable "public_subnet_b" {
  description = "CIDR block for public subnet in AZ B"
  type        = string
}

# Private subnet CIDRs
variable "private_subnet_a" {
  description = "CIDR block for private subnet in AZ A"
  type        = string
}

variable "private_subnet_b" {
  description = "CIDR block for private subnet in AZ B"
  type        = string
}

# Availability Zones
variable "availability_zone_a" {
  description = "The availability zone for Subnet A"
  type        = string
}

variable "availability_zone_b" {
  description = "The availability zone for Subnet B"
  type        = string
}
