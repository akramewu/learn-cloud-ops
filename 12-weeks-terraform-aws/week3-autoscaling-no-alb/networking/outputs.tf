############################################
# Outputs for Networking Module
############################################

# VPC ID
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

# Public subnet IDs
output "public_subnets" {
  description = "List of public subnet IDs"
  value       = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id
  ]
}

# Private subnet IDs
output "private_subnets" {
  description = "List of private subnet IDs"
  value       = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}
