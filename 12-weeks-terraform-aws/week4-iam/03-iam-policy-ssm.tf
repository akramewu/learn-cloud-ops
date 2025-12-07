############################################
# IAM Policy: SSM Access
# Real-world use: Connect to EC2 without SSH keys (more secure)
# Uses AWS Systems Manager Session Manager
############################################

# We use AWS Managed Policy (already created by AWS)
resource "aws_iam_role_policy_attachment" "attach_ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}