############################################
# 1) VPC
############################################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project}-vpc"
    Project = var.project
  }
}

############################################
# 2) Internet Gateway
############################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project}-igw"
    Project = var.project
  }
}

############################################
# 3) Public Subnets
############################################
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_a
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-public-subnet-a"
    Project = var.project
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_b
  availability_zone       = var.availability_zone_b
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project}-public-subnet-b"
    Project = var.project
  }
}

############################################
# 4) Private Subnets
############################################
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_a
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-private-subnet-a"
    Project = var.project
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_b
  availability_zone       = var.availability_zone_b
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-private-subnet-b"
    Project = var.project
  }
}

############################################
# 5) Public Route Table
############################################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  # send all internet traffic to IGW
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.project}-public-rt"
    Project = var.project
  }
}

# associate public subnets to public RT
resource "aws_route_table_association" "public_rt_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

############################################
# 6) NAT Gateway (placed in public_a)
############################################
resource "aws_eip" "nat_eip" {
  domain = "vpc" # instead of deprecated vpc = true
  tags = {
    Name    = "${var.project}-nat-eip"
    Project = var.project
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name    = "${var.project}-nat-gw"
    Project = var.project
  }

  depends_on = [aws_internet_gateway.igw]
}

############################################
# 7) Private Route Table
############################################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # private subnets go to internet via NAT
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name    = "${var.project}-private-rt"
    Project = var.project
  }
}

# Associate private subnets
resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private.id
}
