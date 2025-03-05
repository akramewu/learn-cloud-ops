# IAM Role for EC2 with S3 & DynamoDB Access
resource "aws_iam_role" "ec2_role" {
  name = "EC2Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# IAM Policy for EC2 Access to DynamoDB & S3
resource "aws_iam_policy" "ec2_policy" {
  name        = "EC2Policy"
  description = "Allow EC2 to access S3 & DynamoDB"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:Scan",
        "dynamodb:Query",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

# Attach IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "attach_ec2_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

# IAM Instance Profile for EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_role.name
}

# IAM User for Terraform Management
resource "aws_iam_user" "terraform_user" {
  name = "TerraformUser"

  tags = {
    Name = "TerraformUser"
  }
}

# Attach Admin Policy to Terraform User
resource "aws_iam_user_policy_attachment" "attach_admin_policy" {
  user       = aws_iam_user.terraform_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Create Access Keys for Terraform User
resource "aws_iam_access_key" "terraform_user_key" {
  user = aws_iam_user.terraform_user.name
}