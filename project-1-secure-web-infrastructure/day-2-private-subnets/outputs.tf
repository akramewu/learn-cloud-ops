output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public_subnet.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "private_subnet_1_cidr" {
  description = "The CIDR block of the first private subnet"
  value       = var.private_subnet_1_cidr
}

output "private_subnet_2_cidr" {
  description = "The CIDR block of the second private subnet"
  value       = var.private_subnet_2_cidr
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.nat_gw.id
}