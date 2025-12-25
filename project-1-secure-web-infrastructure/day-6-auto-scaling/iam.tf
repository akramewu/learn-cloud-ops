############################
# create iam role for ec2
############################
resource "aws_iam_role" "ec2_role" {
  name = "${var.project}-ec2-role" # রোলে নাম        
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole" # কোন সার্ভিস এই রোলে অ্যাসিউম করতে পারবে?
        Effect = "Allow"          # অনুমতি দাও
        Principal = {
          Service = "ec2.amazonaws.com" # EC2 সার্ভিস
        }
      }
    ]
  })
  tags = {
    Name    = "${var.project}-ec2-role"
    Project = var.project
  }
}

#############################
# permission policy attchment to role 
#############################
resource "aws_iam_role_policy_attachment" "attach_s3_readonly_policy" {
  role       = aws_iam_role.ec2_role.name                       # কোন রোলে attach করব?
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess" # S3 ReadOnly Managed Policy
}

#############################
# create iam instance profile for ec2
#############################
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project}-ec2-instance-profile" # ইন্সট্যান্স প্রোফাইলের নাম
  role = aws_iam_role.ec2_role.name            # কোন রোলে এই প্রোফাইল জোড়া লাগবে?
  tags = {
    Name    = "${var.project}-ec2-instance-profile"
    Project = var.project
  }
}