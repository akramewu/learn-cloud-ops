variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1" # Change if needed
}


variable "key_name" {
  description = "AWS Key Pair Name"
  type        = string
}

variable "private_key_path" {
  description = "Path to private key"
  type        = string
}

variable "ubuntu_ami" {
  description = "AMI ID"
  type        = string

}

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

## for VPC 

variable "vpc_id" {
  description = "The ID of the VPC where the database subnets exist"
  type        = string
  default     = null # Placeholder, it will be automatically fetched
}



