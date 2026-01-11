############################
# create s3 bucket
############################
resource "aws_s3_bucket" "test_bucket" {
  bucket = "${var.project}-test-bucket-123456" # S3 bucket এর নাম
  #force_destroy = true
  tags = {
    Name    = "${var.project}-test-bucket"
    Project = var.project
  }
}

############################
# Block Public Access (Private করার জন্য)
############################
resource "aws_s3_bucket_public_access_block" "test_bucket_block" {
  bucket = aws_s3_bucket.test_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}