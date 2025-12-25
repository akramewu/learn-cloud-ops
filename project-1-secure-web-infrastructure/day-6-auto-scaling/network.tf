############################
# VPC
# Purpose: Main network container - সব resources এই VPC এর ভিতরে
############################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16" # IP range: 10.0.0.0 to 10.0.255.255
  enable_dns_hostnames = true          # EC2 দের DNS name দিবে

  tags = {
    Name        = "main-vpc"
    Environment = var.environment
    Project     = var.project
  }
}

############################
# Internet Gateway
# Purpose: VPC কে internet এর সাথে connect করে (public subnets এর জন্য)
############################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

############################
# Public Subnet A (eu-west-2a)
# Purpose: Bastion Host এর জন্য - direct internet access
############################
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"           # 256 IPs
  availability_zone = var.availability_zone_a # eu-west-2a

  tags = {
    Name = "main-public-subnet"
  }
}

############################
# Public Subnet B (eu-west-2b)
# Purpose: ALB এর জন্য - minimum 2 AZ দরকার high availability জন্য
############################
resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"           # 256 IPs
  availability_zone = var.availability_zone_b # eu-west-2b

  tags = {
    Name = "main-public-subnet-b"
  }
}

############################
# Public Route Table
# Purpose: Public subnets এর traffic rules - internet access এর জন্য
############################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  # Default route: সব traffic internet gateway দিয়ে বাইরে যাবে
  route {
    cidr_block = "0.0.0.0/0" # All destinations
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.project}-public-rt"
    Project = var.project
  }
}

############################
# Public Route Table Associations
# Purpose: Public subnets দের route table এর সাথে link করা
############################
resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id # Public Subnet A
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rta_b" {
  subnet_id      = aws_subnet.public_subnet_b.id # Public Subnet B
  route_table_id = aws_route_table.public_rt.id
}

############################
# Elastic IP for NAT Gateway
# Purpose: NAT Gateway এর জন্য static public IP
############################
resource "aws_eip" "nat_eip" {
  domain = "vpc" # VPC এর জন্য EIP

  tags = {
    Name = "main-nat-eip"
  }
}

############################
# NAT Gateway
# Purpose: Private subnets থেকে outbound internet access (যেমন: apt update)
# Cost: ~$32/month - সবচেয়ে expensive resource!
############################
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id          # Elastic IP attach
  subnet_id     = aws_subnet.public_subnet.id # Public subnet এ বসবে

  tags = {
    Name = "main-nat-gw"
  }
}

############################
# Private Subnet A (eu-west-2a)
# Purpose: Private EC2 instances (nginx) - no direct internet access
############################
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1_cidr # 10.0.10.0/24
  availability_zone = var.availability_zone_a   # eu-west-2a

  tags = {
    Name = "main-private-subnet-a"
  }
}

############################
# Private Subnet B (eu-west-2b)
# Purpose: Future expansion - additional private instances
############################
resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2_cidr # 10.0.11.0/24
  availability_zone = var.availability_zone_b   # eu-west-2b

  tags = {
    Name = "main-private-subnet-b"
  }
}

############################
# Private Route Table
# Purpose: Private subnets এর traffic rules - outbound শুধু NAT দিয়ে
############################
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  # Outbound internet traffic NAT Gateway দিয়ে যাবে
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name    = "${var.project}-private-rt"
    Project = var.project
  }
}

############################
# Private Route Table Associations
# Purpose: Private subnets দের route table এর সাথে link করা
############################
resource "aws_route_table_association" "private_rt_a" {
  subnet_id      = aws_subnet.private_subnet_a.id # Private Subnet A
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_b" {
  subnet_id      = aws_subnet.private_subnet_b.id # Private Subnet B
  route_table_id = aws_route_table.private_rt.id
}