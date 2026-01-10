############################
# ECR Repository
# Purpose: Store Docker images for validation apps
# - Acts like Docker Hub but private and AWS-integrated
# - Images pulled by EC2 instances for testing
############################
resource "aws_ecr_repository" "validation_apps" {
  name                 = "${var.project}-validation-apps"
  image_tag_mutability = "MUTABLE" # Allow tag updates (e.g., :latest can be overwritten)
  force_delete         = true      # Allow deletion even if images exist n

  image_scanning_configuration {
    scan_on_push = false # Disabled to stay in free tier
  }

  tags = {
    Name    = "${var.project}-validation-app"
    Project = var.project
  }
}

############################
# ECR Lifecycle Policy
# Purpose: Auto-delete old images to save storage costs
# - Keeps only last 2 images
# - Older images automatically expired
# - Prevents unbounded storage growth
############################
resource "aws_ecr_lifecycle_policy" "validation_apps" {
  repository = aws_ecr_repository.validation_apps.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 2 images"
      selection = {
        tagStatus   = "any" # Apply to all tags
        countType   = "imageCountMoreThan"
        countNumber = 2 # Keep 2 most recent
      }
      action = {
        type = "expire" # Delete older images
      }
    }]
  })
}