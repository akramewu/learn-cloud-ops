############################################
# IAM Instance Profile
# Real-world use: EC2 can't use IAM Role directly
# Instance Profile acts as a "bridge" between EC2 and Role
############################################

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project_name}-instance-profile"
  role = aws_iam_role.ec2_role.name
  
  tags = {
    Name    = "${var.project_name}-instance-profile"
    Project = var.project_name
  }
}