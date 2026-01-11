#!/bin/bash
set -e

CONTAINER=$1
PORT=$2

if [ -z "$CONTAINER" ] || [ -z "$PORT" ]; then
  echo "Usage: ./validate.sh <container-name> <port>"
  exit 1
fi

# Check if infrastructure exists
if [ ! -f "../../day-4-iam-roles/terraform.tfstate" ]; then
  echo "ERROR: Infrastructure not deployed"
  echo "Run: cd day-4-iam-roles && terraform apply"
  exit 1
fi

# Get infrastructure IPs
PROJECT_ROOT="$(cd ../.. && pwd)"
BASTION_IP=$(terraform -chdir="${PROJECT_ROOT}/day-4-iam-roles" output -raw bastion_public_ip 2>/dev/null)
PRIVATE_IP=$(terraform -chdir="${PROJECT_ROOT}/day-4-iam-roles" output -raw private_instance_private_ip 2>/dev/null)
S3_BUCKET=$(terraform -chdir="${PROJECT_ROOT}/validation-extension" output -raw validation_bucket_name 2>/dev/null)
AWS_REGION=$(terraform -chdir="${PROJECT_ROOT}/validation-extension" output -raw aws_region 2>/dev/null)

if [ -z "$BASTION_IP" ] || [ -z "$PRIVATE_IP" ]; then
  echo "ERROR: Infrastructure outputs not found"
  echo "Run: cd day-4-iam-roles && terraform apply"
  exit 1
fi

SSH_KEY="$HOME/.ssh/akramul-key.pem"

echo "Validating: $CONTAINER on port $PORT"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
RESULT_FILE="${CONTAINER}-${TIMESTAMP}.json"

# Test on EC2
ssh -i "$SSH_KEY" \
  -o StrictHostKeyChecking=no \
  -o ProxyCommand="ssh -i $SSH_KEY -o StrictHostKeyChecking=no -W %h:%p ubuntu@${BASTION_IP}" \
  ubuntu@${PRIVATE_IP} bash << ENDSSH > "/tmp/${RESULT_FILE}"

STATUS=\$(docker ps --filter "name=${CONTAINER}" --format "{{.Status}}" || echo "not running")
HTTP=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${PORT} || echo "000")

cat << EOF
{
  "container": "${CONTAINER}",
  "port": ${PORT},
  "status": "\${STATUS}",
  "http_code": "\${HTTP}",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

ENDSSH

cat "/tmp/${RESULT_FILE}"

# Upload to S3
aws s3 cp "/tmp/${RESULT_FILE}" "s3://${S3_BUCKET}/results/${RESULT_FILE}" --region ${AWS_REGION}

echo ""
echo "Done"