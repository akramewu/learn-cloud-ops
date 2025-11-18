############################################
# 5) Elastic IP for NAT
############################################
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name    = "${var.project}-nat-eip"
    Project = var.project
  }
}
