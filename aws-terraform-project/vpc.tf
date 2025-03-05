# Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    name = "MainVPC"
  }
}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.10.0/24"
  map_public_ip_on_launch = true  
  availability_zone = var.availability_zones[0]

  tags = {
    name = "public_subnet"
  }
}

# Create Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.11.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    name = "private_subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    name = "InternetGateway"
  }
}

# Create Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    name = "PublicRouteTable"
  }  
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a VPC Endpoint for DynamoDB
resource "aws_vpc_endpoint" "dynamodb_endpoint" {
  vpc_id       = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.eu-west-1.dynamodb"
  vpc_endpoint_type = "Gateway"
  
  route_table_ids = [aws_route_table.public_route_table.id]

  tags = {
    Name = "DynamoDB-VPC-Endpoint"
  }
}