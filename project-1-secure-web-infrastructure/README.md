# Secure Web Infrastructure on AWS

Production-grade multi-tier web application infrastructure using Terraform.

## Architecture Overview
[Complete architecture diagram showing all 6 days together]

## Components
- Multi-AZ VPC with public/private subnets
- Bastion host for secure access
- IAM roles for credential-less access
- Application Load Balancer (code ready)
- Auto Scaling Group (code ready)

## Tech Stack
- Terraform
- AWS (VPC, EC2, IAM, S3, ALB, ASG)
- Ubuntu 22.04
- Nginx

## Repository Structure
```
project-1-secure-web-infrastructure/
├── README.md (this file - project overview)
├── day-1-basic-vpc/ (VPC setup)
├── day-2-private-subnets/ (Private networking)
├── day-3-ec2-bastion/ (Compute & security)
├── day-4-iam-roles/ (Identity & access)
├── day-5-load-balancer/ (High availability)
└── day-6-auto-scaling/ (Auto scaling)
```

## What I Learned
[High-level summary]

## Current Status
✅ Days 1-4: Fully tested and working
⏸️ Days 5-6: Code validated, awaiting AWS account verification


# Secure Web Infrastructure on AWS with Automated Validation

Production-grade multi-tier web application infrastructure with fully automated container deployment and validation system.

## 🏗️ Architecture Overview
```
┌──────────────────────────────────────────────────────────────┐
│                    🌐 INTERNET                                │
└────────────────────────┬─────────────────────────────────────┘
                         │
            ┌────────────▼──────────┐
            │  Internet Gateway     │
            └────────────┬──────────┘
                         │
╔════════════════════════╧══════════════════════════════════════╗
║  VPC: 10.0.0.0/16                                             ║
║                                                                ║
║  ┌─────────────── PUBLIC SUBNETS (Multi-AZ) ─────────────┐   ║
║  │                                                         │   ║
║  │  ╔═══════════════╗         ╔═══════════════╗          │   ║
║  │  ║ eu-west-2a    ║         ║ eu-west-2b    ║          │   ║
║  │  ║ 10.0.1.0/24   ║         ║ 10.0.2.0/24   ║          │   ║
║  │  ║               ║         ║               ║          │   ║
║  │  ║ • Bastion     ║         ║               ║          │   ║
║  │  ║ • NAT Gateway ║         ║               ║          │   ║
║  │  ╚═══════════════╝         ╚═══════════════╝          │   ║
║  └─────────────────────────────────────────────────────────┘   ║
║                         │                                      ║
║                         ▼                                      ║
║  ┌─────────────── PRIVATE SUBNETS ─────────────────────┐      ║
║  │                                                      │      ║
║  │  ╔════════════════╗       ╔═════════════════╗       │      ║
║  │  ║ eu-west-2a     ║       ║ eu-west-2b      ║       │      ║
║  │  ║ 10.0.10.0/24   ║       ║ 10.0.11.0/24    ║       │      ║
║  │  ║                ║       ║                 ║       │      ║
║  │  ║ • Private EC2  ║       ║ (Future ASG)    ║       │      ║
║  │  ║ • Docker       ║       ║                 ║       │      ║
║  │  ║ • AWS CLI      ║       ║                 ║       │      ║
║  │  ╚════════════════╝       ╚═════════════════╝       │      ║
║  └──────────────────────────────────────────────────────┘      ║
╚════════════════════════════════════════════════════════════════╝
```

## 📁 Project Structure
```
project-1-secure-web-infrastructure/
│
├── day-1-basic-vpc/              # VPC + IGW + Public Subnet
├── day-2-private-subnets/        # Private Subnets + NAT Gateway
├── day-3-ec2-bastion/            # Bastion Host + Private EC2
├── day-4-iam-roles/              # IAM Roles + S3 Access
│   ├── main.tf                   # Provider configuration
│   ├── network.tf                # VPC, Subnets, NAT, IGW, Routes
│   ├── security.tf               # Security Groups
│   ├── compute.tf                # EC2 Instances (auto-provisioned)
│   ├── iam.tf                    # IAM Roles + Instance Profiles
│   ├── s3.tf                     # S3 Bucket
│   ├── variables.tf              # Input variables
│   └── outputs.tf                # Output values
│
├── day-5-load-balancer/          # Application Load Balancer (code ready)
├── day-6-auto-scaling/           # Auto Scaling Group (code ready)
│
└── validation-extension/         # 🎯 Automated Validation System
    ├── ecr.tf                    # Docker registry
    ├── s3-validation.tf          # Results storage
    ├── iam-ecr-addon.tf          # ECR permissions
    ├── validation-apps/
    │   └── simple-app/           # Node.js Express app
    │       ├── app.js
    │       ├── package.json
    │       └── dockerfile
    └── scripts/
        └── deploy-test.sh        # Full deployment automation
```

## 🚀 Tech Stack

- **Infrastructure as Code**: Terraform
- **Cloud Provider**: AWS (VPC, EC2, IAM, S3, ECR, NAT Gateway)
- **Operating System**: Ubuntu 22.04 LTS
- **Container Runtime**: Docker
- **Application**: Node.js + Express
- **CI/CD**: GitHub Actions (Terraform validation)
- **Scripting**: Bash

## 🎯 Key Features

### Infrastructure
- ✅ Multi-AZ VPC with public/private subnet separation
- ✅ NAT Gateway for private subnet internet access
- ✅ Bastion host for secure SSH access
- ✅ IAM roles for credential-less AWS access
- ✅ Security groups with least-privilege access

### Automation
- ✅ **Zero manual intervention** deployment
- ✅ Automatic package installation (Docker, AWS CLI, Nginx)
- ✅ Internet connectivity retry logic for NAT Gateway timing
- ✅ Multi-architecture Docker builds (ARM64 → AMD64)
- ✅ Automated testing and validation
- ✅ Results storage in S3

### Security
- ✅ Private EC2 instances (no direct internet access)
- ✅ Bastion host jump pattern
- ✅ Security group isolation
- ✅ IAM instance profiles (no hardcoded credentials)
- ✅ SSH keys excluded from git

## 📊 Infrastructure Components

### Day 4: Core Infrastructure

**Networking:**
- VPC: `10.0.0.0/16`
- Public Subnets: `10.0.1.0/24` (eu-west-2a), `10.0.2.0/24` (eu-west-2b)
- Private Subnets: `10.0.10.0/24` (eu-west-2a), `10.0.11.0/24` (eu-west-2b)
- Internet Gateway + NAT Gateway

**Compute:**
- Bastion Host: t2.micro, Ubuntu 22.04, Public IP
- Private EC2: t2.micro, Ubuntu 22.04, Auto-provisioned with:
  - Docker
  - AWS CLI v2
  - Nginx

**Security:**
- Bastion SG: SSH from specific IP only
- Private SG: SSH from Bastion SG only, HTTP from anywhere

**IAM:**
- EC2 Role with S3 ReadOnly Access
- ECR Pull Permissions
- S3 Validation Write Access

### Validation Extension

**Container Registry:**
- Amazon ECR repository
- AMD64 platform images
- Lifecycle policy (keep last 2 images)

**Validation App:**
- Node.js Express server (Port 3000)
- Endpoints: `/`, `/health`, `/validate`
- Dockerized deployment

**Results Storage:**
- S3 bucket for validation results
- JSON format with timestamps
- Test results and infrastructure metadata

## 🔧 Deployment

### Prerequisites
```bash
# Required tools
- Terraform >= 1.6.0
- AWS CLI configured
- Docker with buildx support
- SSH key pair created in AWS

# SSH key setup
cp /path/to/your-key.pem ~/.ssh/akramul-key.pem
chmod 400 ~/.ssh/akramul-key.pem
```

### Quick Start

**1. Deploy Core Infrastructure:**
```bash
cd day-4-iam-roles

# Create terraform.tfvars
cat > terraform.tfvars << EOF
project              = "day-4"
aws_region           = "eu-west-2"
availability_zone_a  = "eu-west-2a"
availability_zone_b  = "eu-west-2b"
environment          = "dev"
my_ip                = "YOUR_IP_HERE"
ami_id               = "ami-0c76bd4bd302b30ec"  # Ubuntu 22.04
instance_type        = "t2.micro"
ssh_key_name         = "akramul-key"
EOF

# Deploy
terraform init
terraform apply
```

**2. Deploy Validation System:**
```bash
cd ../validation-extension

# Create terraform.tfvars
cat > terraform.tfvars << EOF
project    = "day-4"
aws_region = "eu-west-2"
EOF

# Deploy
terraform init
terraform apply
```

**3. Run Automated Deployment:**
```bash
cd scripts
./deploy-test.sh
```

**Expected Output:**
```
Section 1: Terraform outputs ✅
Section 2: Infrastructure info ✅
Section 3: Build & push Docker (AMD64) ✅
Section 4: Deploy to Private EC2 ✅
Section 5: Test endpoints ✅
Section 6: Upload results to S3 ✅

VALIDATION COMPLETE!
```

## 🔍 Key Problems Solved

### 1. NAT Gateway Timing Issue
**Problem:** cloud-init runs immediately but NAT Gateway takes 2-3 minutes to become ready

**Solution:** Implemented retry loop in user_data:
```bash
for i in {1..30}; do
  if curl -s --max-time 5 http://google.com > /dev/null 2>&1; then
    break
  fi
  sleep 10
done
```

### 2. Docker Architecture Mismatch
**Problem:** Apple Silicon Mac (ARM64) builds incompatible images for AMD64 EC2

**Solution:** Multi-platform Docker builds:
```bash
docker buildx build --platform linux/amd64 --push -t ${ECR_URL}:${TAG} .
```

### 3. Manual Installation Steps
**Problem:** Fresh EC2 instances require manual Docker/AWS CLI installation

**Solution:** Automated provisioning via user_data with internet wait logic

### 4. Credential Management
**Problem:** SSH keys and AWS credentials in code

**Solution:** 
- SSH keys in `~/.ssh/` with proper `.gitignore`
- IAM instance profiles for AWS access (no credentials in code)

## Testing & Validation

### Automated Tests
The validation system automatically tests:
- Container health check
- Application endpoints
- Infrastructure connectivity
- Results stored in S3 with timestamp

### View Test Results
```bash
# List all results
aws s3 ls s3://day-4-validation-results-*/results/ --recursive

# View latest result (with jq)
aws s3 cp s3://YOUR-BUCKET/results/validation-result-TIMESTAMP.json - | jq .

# View latest result (with Python)
aws s3 cp s3://YOUR-BUCKET/results/validation-result-TIMESTAMP.json - | python3 -m json.tool
```

**Sample Result:**
```json
{
  "test_run": "20260111-101749",
  "infrastructure": {
    "bastion_ip": "35.176.126.44",
    "private_ip": "10.0.10.153",
    "aws_region": "eu-west-2"
  },
  "endpoints": {
    "health": {"status":"healthy","uptime_seconds":5},
    "validate": {"validation":"PASSED"},
    "root": {"message":"Infrastructure Working"}
  },
  "status": "PASSED",
  "timestamp": "2026-01-11T10:17:49Z"
}
```

## 💰 Cost Breakdown

**When infrastructure is running:**
- NAT Gateway: ~$0.045/hour = **$32/month** (primary cost)
- EC2 Instances (2x t2.micro): ~$0.01/hour = **$7/month**
- EBS Volumes: ~$1/month
- ECR Storage: Free tier (500MB/month)
- S3 Storage: Negligible (< $0.10/month)

**Total: ~$40/month**

**Cost Optimization:**
- Destroy infrastructure when not in use
- Everything stored in code - can recreate anytime
- `terraform destroy` to save costs

## 🧹 Cleanup
```bash
# Destroy validation system
cd validation-extension
terraform destroy

# Destroy core infrastructure
cd ../day-4-iam-roles
terraform destroy
```

## 📚 What I Learned

### AWS Networking
- Private subnet EC2 instances require NAT Gateway for internet access
- Route tables control traffic flow between subnets
- Security groups provide stateful firewalls
- Multi-AZ deployment for high availability

### Infrastructure as Code
- Terraform state management
- Resource dependencies and ordering
- Output values for inter-module communication
- Variable management and tfvars files

### Docker & Containers
- Multi-architecture builds (ARM64 vs AMD64)
- ECR authentication and image management
- Container networking and port mapping
- Health checks and container lifecycle

### Automation & Scripting
- SSH proxy jumping via bastion hosts
- Bash scripting best practices
- Error handling and fail-fast patterns
- Variable substitution in heredocs

### Security Best Practices
- IAM roles vs hardcoded credentials
- Least-privilege access patterns
- Security group isolation
- SSH key management

### Problem Solving
- NAT Gateway timing issues
- Architecture compatibility
- Credential management
- User data provisioning

## 🎓 Interview Talking Points

**Architecture Decision:**
"I designed a multi-tier architecture with public/private subnet separation. The bastion host provides secure SSH access while keeping application servers isolated in private subnets. NAT Gateway enables internet access for package installation without exposing servers directly."

**Automation Achievement:**
"I built a fully automated deployment pipeline that requires zero manual intervention. From fresh infrastructure to running container with validated endpoints - all automated. The system handles NAT Gateway timing, package installation, multi-architecture Docker builds, and automated testing."

**Problem Solving:**
"When I encountered NAT Gateway timing issues causing cloud-init failures, I implemented a retry loop that waits up to 5 minutes for internet connectivity. This solved the race condition between NAT availability and EC2 provisioning."

**Security Implementation:**
"I implemented defense-in-depth security: private subnets with no direct internet access, bastion host jump pattern, security group isolation, and IAM instance profiles for credential-less AWS access. No secrets in code."

**Production Readiness:**
"This infrastructure follows AWS best practices: Infrastructure as Code with Terraform, automated testing and validation, results storage for audit trails, proper error handling, and comprehensive documentation."

## 🚀 Future Enhancements

- [ ] Add Application Load Balancer (code ready in day-5)
- [ ] Implement Auto Scaling Group (code ready in day-6)
- [ ] Add CloudWatch monitoring and alarms
- [ ] Implement HTTPS with ACM certificates
- [ ] Add RDS database in private subnet
- [ ] Implement blue-green deployment
- [ ] Add automated backup strategy
- [ ] Integrate with CI/CD pipeline
- [ ] Add multiple validation applications
- [ ] Implement scheduled validation runs

## 📄 License

This project is for educational purposes as part of cloud engineering portfolio development.

## 👤 Author

**Akramul Islam**
Cloud Engineer 