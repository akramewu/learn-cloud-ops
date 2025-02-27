provider "aws" {
  region = "eu-west-1"

}
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-tf-test-bucket-6565"
}

# create vpc 
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    name = "main_vpc"
  }
  }

# create subnet for public and private
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.0.0/24"
  map_public_ip_on_launch = true  
  availability_zone = "eu-west-1a"
    tags = {
        name = "public_subnet"
    }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.0.0/16"
  availability_zone = "eu-west-1a"
        tags = {
            name = "private_subnet"
        }
  
}