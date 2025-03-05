variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type        = string
}

variable "public_subnet_cidr" {
    description = "CIDR block for the public subnet"
    type        = string
  
}

variable "private_subnet_cidr" {
    description = "CIDR block for the private subnet"
    type        = string        
  
}

variable "availability_zone" {
    description = "Availability zone"
    type        = string            
  
}

variable "allowed_ssh_ip" {
    description = "IP address to allow SSH access"
    type        = string            
  
}
