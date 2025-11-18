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
