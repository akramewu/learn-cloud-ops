############################
# IAM Policy: ECR Pull Access
# Purpose: Allow EC2 instances to pull Docker images from ECR
# - GetAuthorizationToken: Login to ECR
# - BatchCheckLayerAvailability: Check if image layers exist
# - GetDownloadUrlForLayer: Get URLs to download layers
# - BatchGetImage: Pull complete images
############################
resource "aws_iam_role_policy" "ecr_pull" {
  name = "ecr-pull-policy"
  role = "${var.project}-ec2-role" # Attach to existing Day 4 role

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ]
      Resource = "*" # All ECR repositories
    }]
  })
}