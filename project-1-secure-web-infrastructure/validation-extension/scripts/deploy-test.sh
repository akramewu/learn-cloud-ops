#!/bin/bash
set -e

############################################
# SECTION 1: Terraform Outputs (Validation)
############################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VALIDATION_DIR="$(dirname "$SCRIPT_DIR")"
cd "$VALIDATION_DIR"

echo "Fetching Terraform outputs..."

ECR_URL=$(terraform output -raw ecr_repository_url)
S3_BUCKET=$(terraform output -raw validation_bucket_name)
AWS_REGION=$(terraform output -raw aws_region)

if [[ -z "$ECR_URL" || -z "$AWS_REGION" ]]; then
  echo "ERROR: Failed to read Terraform outputs"
  exit 1
fi

# Immutable, architecture-safe tag
IMAGE_TAG="simple-app-amd64"
APP_IMAGE="${ECR_URL}:${IMAGE_TAG}"

echo "ECR Image: $APP_IMAGE"
echo ""

############################################
# SECTION 2: Day-4 Infrastructure Outputs
############################################

cd ../day-4-iam-roles

BASTION_IP=$(terraform output -raw bastion_public_ip)
PRIVATE_IP=$(terraform output -raw private_instance_private_ip)

if [[ -z "$BASTION_IP" || -z "$PRIVATE_IP" ]]; then
  echo "ERROR: Failed to get Bastion or Private IP"
  exit 1
fi

echo "----------------------------------------"
echo "Bastion IP : $BASTION_IP"
echo "Private IP : $PRIVATE_IP"
echo "AWS Region : $AWS_REGION"
echo "----------------------------------------"
echo ""

############################################
# SECTION 3: Build & Push Docker Image
############################################

echo "Building and pushing Docker image (linux/amd64)..."
cd "$VALIDATION_DIR/validation-apps/simple-app"

docker buildx build \
  --platform linux/amd64 \
  --provenance=false \
  --sbom=false \
  --push \
  -t ${APP_IMAGE} \
  .

echo "Docker image pushed successfully"
echo ""

############################################
# SECTION 4: Deploy via Bastion to Private EC2
############################################

SSH_KEY="${SSH_KEY_PATH:-$HOME/.ssh/akramul-key.pem}"
BASTION_USER="ubuntu"
PRIVATE_USER="ubuntu"

if [ ! -f "$SSH_KEY" ]; then
  echo "ERROR: SSH key not found at $SSH_KEY"
  exit 1
fi

echo "Deploying application to Private EC2..."

ssh -i "$SSH_KEY" \
  -o StrictHostKeyChecking=no \
  -o ProxyCommand="ssh -i $SSH_KEY -o StrictHostKeyChecking=no -W %h:%p ${BASTION_USER}@${BASTION_IP}" \
  ${PRIVATE_USER}@${PRIVATE_IP} bash -s << ENDSSH

set -e

echo "Connected to Private EC2"

# Fail fast if user_data provisioning failed
command -v docker >/dev/null || { echo "ERROR: Docker not installed"; exit 1; }
command -v aws >/dev/null || { echo "ERROR: AWS CLI not installed"; exit 1; }

echo "Logging into ECR..."
aws ecr get-login-password --region ${AWS_REGION} | \
docker login --username AWS --password-stdin ${ECR_URL}

echo "Pulling Docker image..."
docker pull ${APP_IMAGE}

echo "Stopping existing container if present..."
docker stop validation-app 2>/dev/null || true
docker rm validation-app 2>/dev/null || true

echo "Starting container..."
docker run -d \
  --name validation-app \
  -p 3000:3000 \
  ${APP_IMAGE}

sleep 5

echo "Health check:"
curl http://localhost:3000/health

echo "Deployment successful"

ENDSSH

echo ""
echo "----------------------------------------"
echo "Deployment completed successfully"
echo "----------------------------------------"