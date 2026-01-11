# Validation Extension - Automated Container Deployment & Testing

Fully automated system for building, deploying, testing, and validating containerized applications on AWS infrastructure.

## Purpose

This validation extension demonstrates:
- **Zero-touch deployment** from Docker build to running container
- **Multi-architecture support** (ARM64 Mac → AMD64 EC2)
- **Automated testing** with result storage in S3
- **Production-grade practices** for container orchestration

## Architecture
```
┌──────────────────────────────────────────────────────┐
│ Local Development (Mac)                              │
│                                                      │
│  ┌─────────────────────────────────────┐            │
│  │ deploy-test.sh                      │            │
│  │ ├── Build Docker (AMD64)            │            │
│  │ ├── Push to ECR                     │            │
│  │ ├── Deploy via SSH                  │            │
│  │ ├── Run automated tests             │            │
│  │ └── Upload results to S3            │            │
│  └─────────────────────────────────────┘            │
└────────────────┬─────────────────────────────────────┘
                 │
                 ├─────────────────────────────────────┐
                 │                                     │
                 ▼                                     ▼
    ┌────────────────────┐                ┌────────────────────┐
    │  Amazon ECR        │                │  Amazon S3         │
    │  Docker Images     │                │  Test Results      │
    └─────────┬──────────┘                └────────────────────┘
              │
              │ Pull Image
              ▼
    ┌────────────────────────────────────────────────┐
    │  Private EC2 (via Bastion)                     │
    │  ├── Wait for cloud-init                       │
    │  ├── Pull image from ECR                       │
    │  ├── Run container (port 3000)                 │
    │  └── Execute health checks                     │
    └────────────────────────────────────────────────┘
```

## Structure
```
validation-extension/
├── main.tf                    # Provider configuration
├── ecr.tf                     # Docker image registry
├── s3-validation.tf           # Results storage bucket
├── iam-ecr-addon.tf          # ECR pull permissions
├── variables.tf               # Input variables
├── outputs.tf                 # ECR URL, S3 bucket, region
│
├── validation-apps/
│   └── simple-app/            # Node.js Express application
│       ├── app.js             # Server with 3 endpoints
│       ├── package.json       # Dependencies
│       └── dockerfile         # Multi-stage AMD64 build
│
└── scripts/
    └── deploy-test.sh         # Full automation script
```

## Validation App

### Endpoints

**GET /** - Infrastructure info
```json
{
  "message": "Infrastructure Working",
  "hostname": "container-id",
  "time": "2026-01-11T10:17:50.115Z"
}
```

**GET /health** - Health check
```json
{
  "status": "healthy",
  "uptime_seconds": 42,
  "hostname": "container-id",
  "timestamp": "2026-01-11T10:17:50.096Z"
}
```

**GET /validate** - Validation checks
```json
{
  "validation": "PASSED",
  "checks": {
    "server": "running",
    "memory_mb": 8,
    "uptime": 42.5,
    "platform": "linux"
  },
  "timestamp": "2026-01-11T10:17:50.106Z"
}
```

## 🚀 Deployment Script

### Overview

`deploy-test.sh` - Complete automation in 6 sections:

**Section 1: Terraform Outputs**
- Fetch ECR repository URL
- Get S3 bucket name
- Get AWS region

**Section 2: Infrastructure Info**
- Get Bastion host IP
- Get Private EC2 IP
- Verify connectivity

**Section 3: Build & Push**
- Build Docker image for `linux/amd64` platform
- Tag with immutable version
- Push to Amazon ECR

**Section 4: Deploy**
- SSH via Bastion host (jump pattern)
- Wait for cloud-init completion
- Verify Docker and AWS CLI installed
- Login to ECR
- Pull image
- Stop old container (if exists)
- Start new container
- Verify health check

**Section 5: Test & Validate**
- Test all 3 endpoints
- Capture responses
- Generate JSON result with metadata

**Section 6: Upload Results**
- Upload to S3 with timestamp
- Display summary
- Show command to view results

### Usage
```bash
cd validation-extension/scripts
./deploy-test.sh
```

**Requirements:**
- Day 4 infrastructure deployed
- Validation extension deployed
- SSH key at `~/.ssh/akramul-key.pem`
- Docker with buildx support

## 🔧 Setup

### 1. Deploy Infrastructure
```bash
# First deploy Day 4 core infrastructure
cd ../day-4-iam-roles
terraform apply

# Then deploy validation extension
cd ../validation-extension
terraform init
terraform apply
```

### 2. Run Deployment
```bash
cd scripts
./deploy-test.sh
```

### 3. View Results
```bash
# List all test results
aws s3 ls s3://day-4-validation-results-<SUFFIX>/results/ --recursive

# View latest result (with jq)
aws s3 cp s3://day-4-validation-results-<SUFFIX>/results/validation-result-<TIMESTAMP>.json - | jq .

# View latest result (without jq)
aws s3 cp s3://day-4-validation-results-<SUFFIX>/results/validation-result-<TIMESTAMP>.json - | python3 -m json.tool
```

## Test Results Format
```json
{
  "test_run": "20260111-101749",
  "infrastructure": {
    "bastion_ip": "35.176.126.44",
    "private_ip": "10.0.10.153",
    "aws_region": "eu-west-2"
  },
  "endpoints": {
    "health": {
      "status": "healthy",
      "uptime_seconds": 5,
      "hostname": "524733c33b1e",
      "timestamp": "2026-01-11T10:17:50.096Z"
    },
    "validate": {
      "validation": "PASSED",
      "checks": {
        "server": "running",
        "memory_mb": 8,
        "uptime": 5.50626116,
        "platform": "linux"
      },
      "timestamp": "2026-01-11T10:17:50.106Z"
    },
    "root": {
      "message": "Infrastructure Working",
      "hostname": "524733c33b1e",
      "time": "2026-01-11T10:17:50.115Z"
    }
  },
  "status": "PASSED",
  "timestamp": "2026-01-11T10:17:49Z"
}
```

## 🎓 Key Learnings

### Multi-Architecture Docker Builds

**Problem:** Mac with Apple Silicon (ARM64) builds incompatible images for EC2 (AMD64)

**Solution:**
```bash
docker buildx build \
  --platform linux/amd64 \
  --push \
  -t ${ECR_URL}:${TAG} \
  .
```

### Cloud-Init Timing

**Problem:** Container deployment fails because Docker/AWS CLI not installed yet

**Solution:**
```bash
# In deploy script
cloud-init status --wait

# Verify installations
command -v docker || exit 1
command -v aws || exit 1
```

### SSH Proxy Jumping

**Pattern:**
```bash
ssh -i key.pem \
  -o ProxyCommand="ssh -i key.pem -W %h:%p bastion@<IP>" \
  user@<PRIVATE_IP> \
  "commands"
```

### JSON Generation in Bash

**Issue:** Variable substitution in heredocs

**Solution:**
```bash
# Wrong: cat << 'EOF' (single quotes prevent expansion)
# Right: cat << EOF (allows variable expansion)

cat << EOF
{
  "field": "${VARIABLE}"
}
EOF
```

## 🔍 Troubleshooting

### Docker Build Fails
```bash
# Check Docker buildx
docker buildx version

# Create builder if needed
docker buildx create --use
```

### ECR Push Fails
```bash
# Re-authenticate
aws ecr get-login-password --region eu-west-2 | \
  docker login --username AWS --password-stdin <ECR_URL>
```

### SSH Connection Fails
```bash
# Verify key permissions
chmod 400 ~/.ssh/akramul-key.pem

# Test bastion connectivity
ssh -i ~/.ssh/akramul-key.pem ubuntu@<BASTION_IP>

# Test private EC2 via bastion
ssh -i ~/.ssh/akramul-key.pem \
  -o ProxyCommand="ssh -i ~/.ssh/akramul-key.pem -W %h:%p ubuntu@<BASTION_IP>" \
  ubuntu@<PRIVATE_IP>
```

### Cloud-Init Not Complete
```bash
# Check status
ssh -i key.pem ubuntu@<IP> "cloud-init status"

# View logs
ssh -i key.pem ubuntu@<IP> "sudo cat /var/log/cloud-init-output.log"
```

### Container Not Starting
```bash
# Check Docker service
ssh ... "sudo systemctl status docker"

# View container logs
ssh ... "docker logs validation-app"

# Check container status
ssh ... "docker ps -a"
```

## 💡 Best Practices Demonstrated

1. **Immutable Infrastructure**: Rebuild instead of modify
2. **Infrastructure as Code**: All configuration in version control
3. **Automated Testing**: No manual validation steps
4. **Fail-Fast**: Early error detection with explicit checks
5. **Audit Trail**: All test results stored with timestamps
6. **Security**: No credentials in code, IAM roles for access
7. **Documentation**: Clear comments and comprehensive README
8. **Idempotency**: Script can be run multiple times safely

## Future Enhancements

- [ ] Add more validation applications
- [ ] Implement parallel testing
- [ ] Add performance benchmarks
- [ ] Integrate with monitoring (CloudWatch)
- [ ] Add notification system (SNS/email)
- [ ] Implement scheduled runs (EventBridge)
- [ ] Add database validation tests
- [ ] Create validation report dashboard
- [ ] Add integration tests
- [ ] Implement rollback mechanism

## Related Documentation

- [Main Project README](../README.md)
- [Day 4 Infrastructure](../day-4-iam-roles/README.md)
- [Docker Buildx Documentation](https://docs.docker.com/buildx/)
- [AWS ECR User Guide](https://docs.aws.amazon.com/ecr/)

---

**This validation system demonstrates production-grade automation and testing practices for containerized applications on AWS.**