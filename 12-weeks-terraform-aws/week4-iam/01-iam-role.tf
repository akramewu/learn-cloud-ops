############################################
# IAM Role for EC2
# Real-world use: EC2 instances need to access AWS services
############################################

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  # Trust Policy - WHO can assume this role?
  # Answer: Only EC2 service
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "${var.project_name}-ec2-role"
    Project = var.project_name
  }
}