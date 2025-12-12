variable "project" {
  description = "Project name"
  type        = string
  #default     = "my-project"
}
variable "aws_region" {
  description = "AWS Region"
  type        = string
  #default     = "eu-west-2"

}

variable "availability_zone_a" {
  description = "Availability Zone"
  type        = string
}

variable "availability_zone_b" {
  description = "Availability Zone"
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.10.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.11.0/24"
}


variable "environment" {
  description = "Environment tag for resources"
  type        = string
  #default     = "dev"
}

################################
variable "my_ip" {
  description = "My IP address for SSH access"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
} 

variable "ssh_key_name" {
  description = "SSH key pair name in AWS"
  type        = string
  default     = "akramul-key"  # ← তোমার AWS key pair name
}