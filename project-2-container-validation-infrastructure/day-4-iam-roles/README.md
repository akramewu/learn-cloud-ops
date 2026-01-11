# Day 4 - IAM Roles & S3 Access

## Requirements
- VPC CIDR: `10.0.0.0/16`
- Public subnet: `10.0.1.0/24` (eu-west-2a)
- Private subnet: `10.0.10.0/24` (eu-west-2a)
- Region: `eu-west-2` (London)
- S3 Bucket for testing IAM permissions
- IAM Role with Trust Policy (allow EC2 to assume)
- Permission Policy: AWS managed `AmazonS3ReadOnlyAccess`
- IAM Instance Profile to attach role to EC2
- Private EC2 instance with IAM role attached
- Test S3 access without credentials

## Components Built
- S3 bucket (private, blocked public access)
- IAM Role with Trust Policy allowing EC2 service to assume
- IAM Role Policy Attachment (S3 ReadOnly Access)
- IAM Instance Profile linking role to EC2
- Updated Private EC2 instance with instance profile attached
- AWS CLI installed on private instance for testing

## What I Built
Implemented production-level security using IAM roles for EC2 instances to access S3 without hardcoding credentials. The IAM role uses a trust policy to allow only EC2 service to assume it, and has S3 read-only permissions attached. The instance profile acts as a container to pass the IAM role to the EC2 instance. This demonstrates AWS security best practices - no credentials in code, temporary credentials managed automatically, and least privilege access (read-only, not full admin).

## Architecture Diagram
```
Internet (My IP: 31.104.176.250)
    │
    │ SSH (port 22)
    ▼
┌─────────────────────────────────────────────┐
│  Public Subnet (10.0.1.0/24)                │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │  Bastion Host                       │    │
│  │  Public IP: 35.177.56.4             │    │
│  │  Private IP: 10.0.1.x               │    │
│  └──────────┬──────────────────────────┘    │
└─────────────┼───────────────────────────────┘
              │ SSH (port 22)
              ▼
┌─────────────────────────────────────────────┐
│  Private Subnet (10.0.10.0/24)              │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │  Private Web Server                 │    │
│  │  Private IP: 10.0.10.167            │    │
│  │  Instance Profile: ✅               │    │
│  │  └─> IAM Role: ec2-role             │    │
│  │      └─> Trust Policy: EC2 only     │    │
│  │      └─> Permission: S3 ReadOnly    │    │
│  │  Nginx: Running ✅                  │    │
│  └──────────┬──────────────────────────┘    │
└─────────────┼───────────────────────────────┘
              │ S3 API calls (no credentials!)
              ▼
┌─────────────────────────────────────────────┐
│           AWS S3 Service                    │
│                                             │
│  📦 day-3-test-bucket-123456                │
│  📦 akramul-terraform-state-eu-west-2       │
└─────────────────────────────────────────────┘

IAM Flow:
EC2 → Instance Profile → IAM Role → S3 Access
(Temporary credentials auto-managed by AWS)
```

## Files Created
- `main.tf` - Provider configuration
- `network.tf` - VPC, subnets, IGW, NAT, route tables (from Day 3)
- `security.tf` - Security Groups (from Day 3)
- `compute.tf` - EC2 instances with IAM instance profile
- `iam.tf` - S3 bucket, IAM role, trust policy, policy attachment, instance profile
- `variables.tf` - Variable definitions
- `outputs.tf` - Output values including S3 bucket name, IAM role ARN, instance profile name
- `terraform.tfvars.example` - Example values
- `terraform.tfvars` - Actual values (gitignored)

## Commands Used
```bash
# Setup
cd project-1-secure-web-infrastructure
cp -r day-3-ec2-bastion day-4-iam-roles
cd day-4-iam-roles

# Terraform workflow
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply "tfplan"

# Testing
ssh -i akramul-key.pem ubuntu@35.177.56.4
scp -i akramul-key.pem akramul-key.pem ubuntu@35.177.56.4:~/
ssh -i akramul-key.pem ubuntu@35.177.56.4
ssh -i ~/.ssh/akramul-key.pem ubuntu@10.0.10.167

# IAM Role Testing
aws s3 ls                    # List S3 buckets without credentials!
env | grep AWS               # Verify no credentials in environment
curl http://localhost        # Check nginx

terraform destroy  # when done testing
```

## What I Learned
- **IAM Roles**: Roles define what permissions an AWS service has, separate from user credentials
- **Trust Policy (AssumeRole Policy)**: Defines WHO can use the role (in this case, EC2 service)
- **Permission Policy**: Defines WHAT the role can do (in this case, read S3)
- **Instance Profile**: Container that passes IAM role to EC2 (AWS technical requirement)
- **AWS Managed Policies**: Pre-built permission sets by AWS (e.g., `AmazonS3ReadOnlyAccess`)
- **Least Privilege Principle**: Give only the access needed (S3 read, not write/delete)
- **Temporary Credentials**: IAM role provides automatic temporary credentials, no need to hardcode
- **Security Best Practice**: Never hardcode AWS credentials in code or user data
- **Credentials Flow**: EC2 automatically gets temporary credentials via IAM role, refreshed automatically
- **Trust vs Permission**: Trust Policy = who can assume, Permission Policy = what they can do

## Issues I Faced
- **S3 bucket ACL deprecated**: Initial code used `acl = "private"` which no longer works - fixed by using `aws_s3_bucket_public_access_block` resource
- **Global bucket naming**: S3 bucket names must be globally unique across all AWS accounts - used hardcoded suffix instead of random_id for simplicity
- **Instance Profile concept**: Initially confused about why instance profile needed - learned it's AWS's way of attaching IAM roles to EC2
- **Testing confusion**: Initially wondered how IAM would "find" the specific bucket - learned that `AmazonS3ReadOnlyAccess` grants access to ALL S3 buckets in the account
- **Trust Policy syntax**: First time using `jsonencode()` for inline policy - learned proper JSON structure for AssumeRole policy

## Time Taken
~3-4 hours (Day 4)

## Testing Completed
✅ SSH from local machine to Bastion Host  
✅ SSH from Bastion to Private Server  
✅ AWS CLI installed on private instance  
✅ S3 bucket list command successful without credentials  
✅ Verified no AWS credentials in environment variables (`env | grep AWS` returned nothing)  
✅ IAM Role ARN output verified: `arn:aws:iam::980826468379:role/day-3-ec2-role`  
✅ Instance Profile attached correctly  
✅ S3 ReadOnly access working (can list buckets)  
✅ Cannot write to S3 (verified read-only permission)  
✅ Nginx serving custom page  
✅ Temporary credentials automatically managed by AWS  

## Test Results
```bash
# S3 Access Test (SUCCESS - No credentials needed!)
ubuntu@ip-10-0-10-167:~$ aws s3 ls
2025-11-30 22:55:23 akramul-terraform-state-eu-west-2
2025-12-14 21:50:50 day-3-test-bucket-123456

# Credentials Check (SUCCESS - No hardcoded credentials!)
ubuntu@ip-10-0-10-167:~$ env | grep AWS
(no output - proves IAM role is providing temporary credentials automatically)

# Nginx Check (SUCCESS)
ubuntu@ip-10-0-10-167:~$ curl http://localhost
<h1>Hello from Private Server!</h1>
<p>Hostname: ip-10-0-10-167</p>
<p>Private IP: 10.0.10.167 </p>
<p>OS: Ubuntu</p>
```

## Key Concepts Demonstrated
- **No Hardcoded Credentials**: EC2 accesses S3 without any AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY
- **Automatic Credential Management**: AWS provides temporary credentials via IAM role, auto-refreshed
- **Principle of Least Privilege**: Used ReadOnly access, not full S3 admin permissions
- **Trust Relationships**: Only EC2 service can assume this role, not users or other services
- **Instance Profiles**: Bridge between IAM roles and EC2 instances
- **Production Security Pattern**: This is how AWS credentials should be managed in production