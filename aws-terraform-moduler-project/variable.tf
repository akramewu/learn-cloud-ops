# AWS General Variables
variable "region" {
  description = "AWS Region"
  type        = string
}

# VPC Configuration
variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
}

variable "public_subnet_cidr" {
  description = "Public Subnet CIDR Block"
  type        = string
}

variable "private_subnet_cidr" {
  description = "Private Subnet CIDR Block"
  type        = string
}

variable "availability_zone" {
  description = "AWS Availability Zone"
  type        = string
}

variable "allowed_ssh_ip" {
  description = "Allowed SSH CIDR (replace with your IP)"
  type        = string
}

# EC2 Configuration
variable "ami_id" {
  description = "AMI ID for EC2"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "key_name" {
  description = "SSH Key Pair"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private key"
  type        = string
  
}

# S3 and DynamoDB Configuration
variable "bucket_name" {
  description = "S3 Bucket Name"
  type        = string
}

variable "dynamodb_name" {
  description = "DynamoDB Table Name"
  type        = string
}
