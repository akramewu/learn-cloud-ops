# Project 2: Container Validation Infrastructure

Infrastructure for validating any containerized application. Built for daily practice and learning.

## What This Does

- Provides AWS infrastructure (VPC, EC2, NAT, Bastion)
- Deploy ANY container manually
- Validate it automatically
- Store results in S3

## Difference from Project 1

**Project 1:** Fixed app, full automation
**Project 2:** Any app, flexible validation


# Container Validation Infrastructure - Complete Setup & Daily Usage Guide

AWS infrastructure for deploying and validating any containerized application.

## Purpose

- Practice deploying different containers daily
- Flexible validation for any containerized application
- Track progress with S3 storage
- Build hands-on infrastructure experience

## Structure
```
project-2-container-validation-infrastructure/
├── README.md
├── DEPLOY.md
├── day-4-iam-roles/             # Core infrastructure
│   ├── main.tf
│   ├── network.tf
│   ├── security.tf
│   ├── compute.tf
│   ├── iam.tf
│   └── s3.tf
└── validation-extension/        # Validation system
    ├── ecr.tf
    ├── s3-validation.tf
    ├── iam-ecr-addon.tf
    └── scripts/
        └── validate.sh.         # Validation script
```

---

## WORKFLOW: Complete Setup to Daily Validation

### PHASE 1: ONE-TIME INFRASTRUCTURE SETUP

#### Step 1: Deploy Core Infrastructure
```bash
cd ~/learn-cloud-ops/project-2-container-validation-infrastructure/day-4-iam-roles

cat > terraform.tfvars << EOF
project              = "day-4"
aws_region           = "eu-west-2"
availability_zone_a  = "eu-west-2a"
availability_zone_b  = "eu-west-2b"
environment          = "dev"
my_ip                = "YOUR_PUBLIC_IP_HERE"
ami_id               = "ami-0c76bd4bd302b30ec"
instance_type        = "t2.micro"
ssh_key_name         = "akramul-key"
EOF

terraform init
terraform apply
```

Type: `yes`

Wait: 5-7 minutes

---

#### Step 2: Deploy Validation System
```bash
cd ../validation-extension

cat > terraform.tfvars << EOF
project    = "day-4"
aws_region = "eu-west-2"
EOF

terraform init
terraform apply
```

Type: `yes`

Wait: 2 minutes

---

#### Step 3: Save Infrastructure Details
```bash
cd ../day-4-iam-roles

BASTION_IP=$(terraform output -raw bastion_public_ip)
PRIVATE_IP=$(terraform output -raw private_instance_private_ip)

echo "Bastion IP:  $BASTION_IP"
echo "Private IP:  $PRIVATE_IP"
```

Write these IPs down - you'll use them daily.

---

### PHASE 2: DAILY VALIDATION WORKFLOW

#### Step 1: Connect to Private EC2
```bash
ssh -i ~/.ssh/akramul-key.pem \
  -o ProxyCommand="ssh -i ~/.ssh/akramul-key.pem -W %h:%p ubuntu@<BASTION_IP>" \
  ubuntu@<PRIVATE_IP>
```

Example:
```bash
ssh -i ~/.ssh/akramul-key.pem \
  -o ProxyCommand="ssh -i ~/.ssh/akramul-key.pem -W %h:%p ubuntu@52.56.116.4" \
  ubuntu@10.0.10.39
```

---

#### Step 2: Deploy Container

Example A: Nginx
```bash
docker run -d --name web-server -p 8080:80 nginx:alpine
```

Example B: Node.js API
```bash
docker run -d --name api-server -p 3000:3000 node:18-alpine \
  node -e "require('http').createServer((req,res)=>res.end(JSON.stringify({status:'ok'}))).listen(3000)"
```

Example C: Python Server
```bash
docker run -d --name python-app -p 5000:5000 python:3.9-alpine \
  python -m http.server 5000
```

Example D: Your Custom App
```bash
docker pull <YOUR_ECR_URL>:tag
docker run -d --name my-app -p 3000:3000 <YOUR_ECR_URL>:tag
```

---

#### Step 3: Verify Container
```bash
docker ps
```

---

#### Step 4: Exit EC2
```bash
exit
```

---

#### Step 5: Run Validation
```bash
cd ~/learn-cloud-ops/project-2-container-validation-infrastructure/validation-extension/scripts

./validate.sh <container-name> <port>
```

Example:
```bash
./validate.sh web-server 8080
```

Expected Output:
```json
{
  "container": "web-server",
  "port": 8080,
  "status": "Up 2 minutes",
  "http_code": "200",
  "timestamp": "2026-01-11T22:04:20Z"
}
Done
```

---

#### Step 6: View Results
```bash
aws s3 ls s3://day-4-validation-results-*/results/
```

View specific result:
```bash
aws s3 cp s3://day-4-validation-results-*/results/<filename>.json - | python3 -m json.tool
```

---

### PHASE 3: COST MANAGEMENT

Destroy infrastructure to save costs (~$40/month):
```bash
cd ~/learn-cloud-ops/project-2-container-validation-infrastructure/validation-extension
terraform destroy

cd ../day-4-iam-roles
terraform destroy
```

Recreate when needed:
```bash
terraform apply  # in both directories
```

---

## Validation Results
```json
{
  "container": "web-server",
  "port": 8080,
  "status": "Up 5 minutes",
  "http_code": "200",
  "timestamp": "2026-01-11T22:04:20Z"
}
```

Fields:
- `container`: Container name
- `port`: Port tested
- `status`: Docker status
- `http_code`: HTTP response (200 = success, 000 = failed)
- `timestamp`: When validation ran

---

## Troubleshooting

### Cannot SSH to EC2

Get IPs:
```bash
cd day-4-iam-roles
terraform output bastion_public_ip
terraform output private_instance_private_ip
```

Check key permissions:
```bash
chmod 400 ~/.ssh/akramul-key.pem
```

---

### Validation Script Fails

Check infrastructure:
```bash
cd day-4-iam-roles
terraform state list
```

---

### Container Not Starting

Check logs:
```bash
docker logs <container-name>
```

---

## Container Management

List containers:
```bash
docker ps
```

Stop container:
```bash
docker stop <container-name>
```

Remove container:
```bash
docker rm <container-name>
```

Remove all:
```bash
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
```

---

## Cost Breakdown

Monthly costs when running:
- NAT Gateway: $32/month
- EC2 (2x t2.micro): $7/month
- EBS: $1/month
- S3: <$0.10/month
- Total: ~$40/month