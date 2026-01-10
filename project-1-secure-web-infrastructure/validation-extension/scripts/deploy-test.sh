#!/bin/bash
set -e

echo " Getting Infrastructure Info from Terraform..."
echo ""

# Navigate to validation-extension (where terraform state is located)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VALIDATION_DIR="$(dirname "$SCRIPT_DIR")"
cd "$VALIDATION_DIR"
echo " Current Directory: $SCRIPT_DIR"

# Get ECT URL from terraform output
echo " Fetching ECR Repository URL..."
ECR_URL=$(terraform output -raw ecr_repository_url 2>/dev/null)
echo "ECR Repository URL: $ECR_URL"

if [ -z "$ECR_URL" ]; then
  echo "Error: Could not get ECR URL"
  exit 1
fi

# Build full image name
APP_IMAGE="${ECR_URL}:simple-app-latest"
echo "Full image name: $APP_IMAGE"
echo ""

# Get S3 Bucket 
echo "Getting S3 bucket name..."
S3_BUCKET=$(terraform output -raw validation_bucket_name 2>/dev/null)

if [ -z "$S3_BUCKET" ]; then
  echo "Error: Could not get S3 bucket name"
  exit 1
fi

# Get AWS region
echo "Getting AWS region..."
AWS_REGION=$(terraform output -raw aws_region 2>/dev/null)

if [ -z "$AWS_REGION" ]; then
  echo "Error: Could not get AWS region"
  exit 1
fi

# Get Day 4 infrastructure info
echo "Getting Day 4 infrastructure info..."
cd ../day-4-iam-roles


BASTION_IP=$(terraform output -raw bastion_public_ip 2>/dev/null)
PRIVATE_IP=$(terraform output -raw private_instance_private_ip 2>/dev/null)

if [ -z "$BASTION_IP" ] || [ -z "$PRIVATE_IP" ]; then
  echo "Error: Could not get instance IPs from Day 4"
  exit 1
fi

# Success - show everything!
echo ""
echo "All Infrastructure Info Retrieved!"
echo "========================================"
echo "ECR URL:     $ECR_URL"
echo "S3 Bucket:   $S3_BUCKET"
echo "AWS Region:  $AWS_REGION"
echo "Bastion IP:  $BASTION_IP"
echo "Private IP:  $PRIVATE_IP"
echo "========================================"
echo "" 

# Build Docker Image
echo " Building Docker Image..."
cd "$VALIDATION_DIR/validation-apps/simple-app"

docker build -t validation-app .

if [ $? -ne 0 ]; then
  echo "Error: Docker build failed"
  exit 1
fi
echo " Docker Image Built Successfully!"
echo ""

# Tag for ECR
echo " Tagging Docker Image for ECR..."
docker tag validation-app:latest ${APP_IMAGE}

# Login to ECR
echo " Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $ECR_URL

if [ $? -ne 0 ]; then
  echo "Error: ECR login failed"
  exit 1
fi
echo " Logged into ECR Successfully!"
echo ""

# Push to ECR
echo " Pushing Docker Image to ECR..."
docker push ${APP_IMAGE}

if [ $? -ne 0 ]; then
  echo "Error: Docker push failed"
  exit 1
fi
echo " Docker Image Pushed Successfully!"
echo ""
echo "=========================================="
echo "Docker Build & Push Complete!"
echo "=========================================="


# Section 3: Deploy 
# - SSH to Private EC2
# - Pull image from ECR
# - Run container

# SSH Configuration
SSH_KEY="${SSH_KEY_PATH:-$HOME/.ssh/akramul-key.pem}"
BASTION_USER="ubuntu"
PRIVATE_USER="ubuntu"

echo "📋 SSH Configuration:"
echo "  Bastion: $BASTION_USER@$BASTION_IP"
echo "  Private: $PRIVATE_USER@$PRIVATE_IP"
echo "  SSH Key: $SSH_KEY"
echo ""

# Check if SSH key exists
if [ ! -f "$SSH_KEY" ]; then
  echo "Error: SSH key not found at: $SSH_KEY"
  echo ""
  echo "📖 Setup Instructions:"
  echo "1. Place your AWS key at: ~/.ssh/akramul-key.pem"
  echo "2. Set permissions: chmod 400 ~/.ssh/akramul-key.pem"
  echo "3. Or set custom path: export SSH_KEY_PATH=/path/to/your/key.pem"
  exit 1
fi

echo "🔐 Deploying via SSH jump (Bastion → Private EC2)..."
echo ""

# SSH to Private EC2 via Bastion and deploy
ssh -i "$SSH_KEY" \
  -o StrictHostKeyChecking=no \
  -o ProxyCommand="ssh -i $SSH_KEY -o StrictHostKeyChecking=no -W %h:%p $BASTION_USER@$BASTION_IP" \
  $PRIVATE_USER@$PRIVATE_IP bash -s << ENDSSH
set -e

echo "Connected to Private EC2!"
echo ""

# Login to ECR
echo "Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $ECR_URL

if [ \$? -ne 0 ]; then
  echo "ECR login failed on Private EC2"
  exit 1
fi
echo "ECR login successful"
echo ""

# Pull Docker image
echo "Pulling Docker image from ECR..."
docker pull $APP_IMAGE

if [ \$? -ne 0 ]; then
  echo "Docker pull failed"
  exit 1
fi
echo "Image pulled successfully"
echo ""

# Stop and remove old container (if exists)
echo "Stopping old container (if exists)..."
docker stop validation-app 2>/dev/null || true
docker rm validation-app 2>/dev/null || true
echo "Old container cleaned up"
echo ""

# Run new container
echo "🚀 Starting new container..."
docker run -d \
  --name validation-app \
  -p 3000:3000 \
  $APP_IMAGE

if [ \$? -ne 0 ]; then
  echo "Container failed to start"
  exit 1
fi
echo "Container started successfully!"
echo ""

# Wait for container to be ready
echo "Waiting for app to be ready..."
sleep 5

# Check if container is running
if docker ps | grep -q validation-app; then
  echo "Container is running!"
  docker ps | grep validation-app
else
  echo "Container not running"
  docker logs validation-app
  exit 1
fi

ENDSSH

echo ""
echo "=========================================="
echo "Deployment to Private EC2 Complete!"
echo "=========================================="
echo ""

# Section 4: Test ⏳ NEXT
# - Call /health endpoint
# - Call /validate endpoint
# - Save results

# Section 5: Upload ⏳ FINAL
# - Upload results to S3
# - Print summary
```
