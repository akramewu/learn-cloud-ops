############################################
# 6) NAT Gateway (Public Subnet A)
############################################
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name    = "${var.project}-nat-gw"
    Project = var.project
  }

  # NAT depends on IGW being attached, otherwise routing fails
  depends_on = [aws_internet_gateway.igw]
}
