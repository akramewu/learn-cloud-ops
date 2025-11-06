# variable for vpc cidr block
variable "project" {
    description = "Project Tag prefix"
    type        = string
    default     = "learn-cloud-ops-week2"
}

variable "vpc_cidr" {
  description = "VPC CIDR Block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_a" {
  description = "Public Subnet A CIDR Block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_b" {
  description = "Public Subnet B CIDR Block"
  type        = string
  default     = "10.0.2.0/24"
}

#private subnet variables
variable "private_subnet_a" {
  description = "Private Subnet A CIDR Block"
  type        = string
  default     = "10.0.11.0/24"  
}
variable "private_subnet_b" {
  description = "Private Subnet B CIDR Block"
  type        = string
  default     = "10.0.12.0/24"
}

# variable for availability zones
variable "availability_zone_a" {
    description = "Availability Zone A"
    type        = string
    default     = "eu-west-2a"
}
variable "availability_zone_b" {
    description = "Availability Zone B"
    type        = string
    default     = "eu-west-2b"
} 
