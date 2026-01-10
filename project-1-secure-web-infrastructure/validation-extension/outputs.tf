############################
# Output: ECR Repository URL
# Purpose: Use in build scripts to push Docker images
# Example: 123456789012.dkr.ecr.eu-west-2.amazonaws.com/day-4-validation-apps
############################
output "ecr_repository_url" {
  description = "ECR repository URL for validation apps"
  value       = aws_ecr_repository.validation_apps.repository_url
}

############################
# Output: S3 Bucket Name
# Purpose: Use in scripts to download validation results
# Example: day-4-validation-results-a3f7b2c1
############################
output "validation_bucket_name" {
  description = "S3 bucket name for validation results"
  value       = aws_s3_bucket.validation_results.id
}

############################
# Output: AWS Region
# Purpose: Use in deployment scripts for ECR login and API calls
# Example: eu-west-2
############################
output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}