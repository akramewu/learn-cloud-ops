############################
# Bastion Host Outputs
############################
output "bastion_public_ip" {
  description = "Public IP of Bastion Host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_public_dns" {
  description = "Public DNS of Bastion Host"
  value       = aws_instance.bastion.public_dns # ← ঠিক করলাম (bastion + public_dns)
}

############################
# Private Server Outputs
############################
output "private_instance_private_ip" {
  description = "Private IP of Web Server"
  value       = aws_instance.app_server.private_ip
}

############################
# Security Group Outputs
############################
output "bastion_sg_id" {
  description = "Bastion Security Group ID"
  value       = aws_security_group.bastion_sg.id
}

output "private_sg_id" {
  description = "Private Security Group ID"
  value       = aws_security_group.private_sg.id
}

############################
# Day 4 - IAM & S3 Outputs
############################

output "s3_bucket_name" {
  description = "Name of the S3 test bucket"
  value       = aws_s3_bucket.test_bucket.id
}

output "iam_role_arn" {
  description = "ARN of the IAM role for EC2"
  value       = aws_iam_role.ec2_role.arn
}

output "instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}