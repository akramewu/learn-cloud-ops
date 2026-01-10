############################
# Variable: Project Name
# Purpose: Prefix for all resource names
# - Used for naming: "${var.project}-resource-name"
# - Helps identify resources in AWS console
# - Example: "day-4"
############################
variable "project" {
  description = "Project name"
  type        = string
}

############################
# Variable: AWS Region
# Purpose: Define deployment region
# - Used in provider configuration
# - Used in scripts for ECR login
# - Example: "eu-west-2"
############################
variable "aws_region" {
  description = "AWS Region"
  type        = string
}