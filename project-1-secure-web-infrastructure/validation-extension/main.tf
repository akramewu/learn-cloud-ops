############################
# Terraform Configuration
# Purpose: Define required providers and versions
# - AWS provider: Infrastructure resources
# - Random provider: Generate unique identifiers
############################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" # AWS provider version
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0" # Random provider version
    }
  }
}

############################
# AWS Provider Configuration
# Purpose: Configure AWS region for resource deployment
# - Region set via variable for flexibility
############################
provider "aws" {
  region = var.aws_region
}