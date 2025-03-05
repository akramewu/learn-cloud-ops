# General AWS Configuration
variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-west-1"
}

# Networking Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

# Security Configuration
variable "allowed_ssh_ip" {
  description = "IP address allowed for SSH access"
  type        = string
  sensitive   = true
}

variable "ssh_port" {
  description = "Port for SSH access"
  type        = number
  default     = 22
}

# Compute Variables
variable "key_name" {
  description = "Name of the AWS SSH key pair"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private SSH key"
  type        = string
  sensitive   = true
}

variable "ubuntu_ami" {
  description = "Ubuntu AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

# Database Variables
variable "db_username" {
  description = "Database admin username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Database connection port"
  type        = number
  default     = 5432
}

# Application Configuration
variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "my-app"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "development"
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production"
  }
}

# Auto Scaling Configuration
variable "min_instances" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 3
}

# Networking Security
variable "ingress_cidr_blocks" {
  description = "CIDR blocks allowed for ingress"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}