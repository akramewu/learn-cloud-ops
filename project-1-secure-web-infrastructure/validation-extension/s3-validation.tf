############################
# Random Suffix for S3 Bucket
# Purpose: S3 bucket names must be globally unique
# - Generates random 4-byte hex string (8 characters)
# - Example: day-4-validation-results-a3f7b2c1
############################
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

############################
# S3 Bucket for Validation Results
# Purpose: Store validation test results as JSON files
# - Each test run creates timestamped JSON file
# - Results include: pass/fail status, test details, timestamp
# - Accessible via AWS CLI for review
############################
resource "aws_s3_bucket" "validation_results" {
  bucket = "${var.project}-validation-results-${random_id.bucket_suffix.hex}"
  force_destroy = true  # Allow deletion even if objects exist

  tags = {
    Name    = "${var.project}-validation-results"
    Project = var.project
  }
}

############################
# Block All Public Access to S3 Bucket
# Purpose: Security - ensure results are private
# - block_public_acls: Block public ACLs
# - block_public_policy: Block public bucket policies
# - ignore_public_acls: Ignore existing public ACLs
# - restrict_public_buckets: Restrict public bucket policies
############################
resource "aws_s3_bucket_public_access_block" "validation_results" {
  bucket = aws_s3_bucket.validation_results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################
# IAM Policy: S3 Write Access
# Purpose: Allow EC2 instances to upload validation results
# - PutObject: Upload JSON result files
# - GetObject: Download/read existing results
# - Resource: Only this specific bucket
############################
resource "aws_iam_role_policy" "s3_validation_addon" {
  name = "s3-validation-policy"
  role = "${var.project}-ec2-role" # Attach to existing Day 4 role

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject", # Upload results
        "s3:GetObject"  # Download results
      ]
      Resource = "${aws_s3_bucket.validation_results.arn}/*" # Dynamic reference
    }]
  })
}