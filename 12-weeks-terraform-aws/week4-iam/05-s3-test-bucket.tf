############################################
# Test S3 Bucket
# Real-world use: Store application config files, logs, etc.
############################################

# Random suffix for unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket
resource "aws_s3_bucket" "test_bucket" {
  bucket = "${var.project_name}-test-${random_id.bucket_suffix.hex}"

  tags = {
    Name    = "${var.project_name}-test-bucket"
    Project = var.project_name
  }
}

# Upload a test file
resource "aws_s3_object" "test_file" {
  bucket  = aws_s3_bucket.test_bucket.id
  key     = "config/app-config.txt"
  content = <<-EOF
    # Application Configuration
    APP_NAME=MyApp
    APP_VERSION=1.0.0
    ENVIRONMENT=production
  EOF

  content_type = "text/plain"

  tags = {
    Name    = "test-config-file"
    Project = var.project_name
  }
}