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

variable "availability_zone" {
  description = "Availability Zone"
  type = string
}

variable "environment" {
   description = "Environment tag for resources"
   type        = string
   #default     = "dev"
}