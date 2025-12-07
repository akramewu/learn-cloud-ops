############################################
# IAM Policy: S3 Read-Only
# Real-world use: Application reads config files from S3
# Least Privilege: Only GET and LIST, NO DELETE/WRITE
############################################

resource "aws_iam_policy" "s3_readonly" {
  name        = "${var.project_name}-s3-readonly-policy"
  description = "Allow EC2 to read S3 objects only"

  # WHAT can this role do?
  # Answer: Only read from S3, nothing else
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3ReadOnly"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-s3-readonly"
    Project = var.project_name
  }
}

# Attach S3 Policy to Role
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_readonly.arn
}