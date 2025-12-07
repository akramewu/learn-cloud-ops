############################################
# Outputs - Important Information
############################################

output "ec2_instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.app_server.id
}

output "ec2_public_ip" {
  description = "EC2 Public IP"
  value       = aws_instance.app_server.public_ip
}

output "iam_role_name" {
  description = "IAM Role Name"
  value       = aws_iam_role.ec2_role.name
}

output "iam_role_arn" {
  description = "IAM Role ARN"
  value       = aws_iam_role.ec2_role.arn
}

output "instance_profile_name" {
  description = "Instance Profile Name"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}

output "s3_bucket_name" {
  description = "Test S3 Bucket Name"
  value       = aws_s3_bucket.test_bucket.id
}

output "s3_test_file_path" {
  description = "S3 Test File Path"
  value       = "s3://${aws_s3_bucket.test_bucket.id}/config/app-config.txt"
}

output "ssm_connect_command" {
  description = "Command to connect to EC2 via SSM"
  value       = "aws ssm start-session --target ${aws_instance.app_server.id}"
}