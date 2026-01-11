# Day 5 - Application Load Balancer

## Requirements
- VPC CIDR: `10.0.0.0/16`
- Public subnets: `10.0.1.0/24` (eu-west-2a), `10.0.2.0/24` (eu-west-2b)
- Private subnet: `10.0.10.0/24` (eu-west-2a)
- Region: `eu-west-2` (London)
- Application Load Balancer (internet-facing)
- Target Group with health checks
- ALB Listener on port 80
- Multi-AZ deployment (minimum 2 AZs)
- ALB Security Group (allow port 80 from internet)
- Update Private SG (allow port 80 from ALB only)

## Components Built
- Second public subnet in eu-west-2b (multi-AZ requirement)
- ALB Security Group (port 80 from 0.0.0.0/0)
- Application Load Balancer (internet-facing, multi-AZ)
- Target Group with health check configuration
- ALB Listener (port 80 HTTP → Target Group)
- Target Group Attachment (Private EC2 registered)
- Updated Private Security Group (port 80 from ALB SG only)

## What I Built
Designed complete Application Load Balancer architecture to distribute traffic across EC2 instances in private subnets. The ALB sits in public subnets across two availability zones (eu-west-2a and eu-west-2b) for high availability. Traffic flows from internet users to the ALB, which forwards requests to registered targets in the target group after performing health checks. The private EC2 instance was updated to accept traffic only from the ALB security group, following security best practices of not exposing backend servers directly to the internet.

## Architecture Diagram
```
Internet (Users)
    │
    │ HTTP (port 80)
    ▼
┌─────────────────────────────────────────────┐
│  Public Subnets (Multi-AZ)                  │
│                                             │
│  ┌──────────────────┐  ┌──────────────────┐│
│  │ eu-west-2a       │  │ eu-west-2b       ││
│  │ 10.0.1.0/24      │  │ 10.0.2.0/24      ││
│  │                  │  │                  ││
│  │  ┌────────────┐  │  │  ┌────────────┐  ││
│  │  │ Bastion    │  │  │  │            │  ││
│  │  └────────────┘  │  │  │            │  ││
│  │                  │  │                  ││
│  │  Application Load Balancer (Spans both) ││
│  │  Security Group: alb-sg                 ││
│  │  Listener: Port 80 → Target Group       ││
│  └──────────────────┘  └──────────────────┘│
└─────────────────────────────────────────────┘
    │
    │ Health Check: GET / every 30s
    ▼
┌─────────────────────────────────────────────┐
│  Target Group                               │
│  Protocol: HTTP, Port: 80                   │
│  Health: 2 success = healthy                │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  Private Subnet (10.0.10.0/24)              │
│                                             │
│  ┌─────────────────────────────────────┐    │
│  │  Private EC2 (nginx)                │    │
│  │  Private IP: 10.0.10.x              │    │
│  │  Security Group: private-sg         │    │
│  │  Port 80: ALB SG only ✅            │    │
│  │  IAM Role: S3 ReadOnly              │    │
│  └─────────────────────────────────────┘    │
└─────────────────────────────────────────────┘

Traffic Flow:
Internet → ALB (port 80) → Target Group (health check) → Private EC2 (nginx)
```

## Files Created/Modified
- `alb.tf` - Application Load Balancer, Target Group, Listener, Attachment
- `network.tf` - Added public_subnet_b in eu-west-2b
- `security.tf` - Added alb_sg, updated private_sg (port 80 from ALB only)
- `outputs.tf` - Added alb_dns_name output
- `terraform.tfvars.example` - Example values
- `terraform.tfvars` - Actual values (gitignored)

## Commands Used
```bash
# Setup
cd project-1-secure-web-infrastructure
cp -r day-4-iam-roles day-5-load-balancer
cd day-5-load-balancer

# Terraform workflow
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply "tfplan"  # Failed due to account limitation

# Cleanup
terraform destroy  # Successfully destroyed all resources
```

## What I Learned
- **Application Load Balancer (ALB)**: Layer 7 load balancer that distributes HTTP/HTTPS traffic
- **Target Groups**: Container for EC2 instances that receive traffic from ALB
- **Health Checks**: ALB automatically checks instance health and routes traffic only to healthy targets
- **Multi-AZ Requirement**: ALB requires minimum 2 subnets in different availability zones for high availability
- **Listener**: Defines what port ALB listens on and where to forward traffic
- **Target Registration**: EC2 instances must be manually registered to target group (without Auto Scaling)
- **Security Group Chaining**: Private instances accept traffic only from ALB security group, not from internet
- **ALB vs NLB**: Application Load Balancer works at HTTP layer (L7), Network Load Balancer at TCP layer (L4)
- **DNS Name**: ALB provides auto-generated DNS name for accessing the application
- **AWS Account Limitations**: New accounts may have restrictions requiring verification before using certain services

## Issues I Faced
- **AWS Account Limitation - Load Balancer Creation Blocked**: 
```
  Error: operation error Elastic Load Balancing v2: CreateLoadBalancer
  StatusCode: 400, OperationNotPermitted
  Message: This AWS account currently does not support creating load balancers
```
  **Root Cause:** New AWS accounts require verification before enabling load balancer creation
  
  **Action Taken:** 
  - Created AWS Support case #176615986800533
  - Completed account verification steps (payment method, phone number, contact info)
  - Destroyed all infrastructure to avoid costs while waiting for resolution
  
  **Status:** Awaiting AWS Support response (24-48 hours expected)

- **Multi-AZ Requirement Understanding**: Initially had only one public subnet, learned ALB requires minimum 2 AZs - added public_subnet_b in eu-west-2b

- **Security Group Configuration**: Had to update private_sg from allowing port 80 from 0.0.0.0/0 to accepting only from alb_sg - security best practice

- **Target Group Attachment**: Initially confused about why attachment needed - learned target groups are empty containers until instances are manually registered

## Time Taken
~3-4 hours (Day 5)

## Testing Status
❌ **Deployment Blocked** - Unable to test due to AWS account limitation  
✅ **Code Validated** - terraform validate successful  
✅ **Architecture Designed** - Complete infrastructure code ready  
⏳ **Pending** - Awaiting AWS Support case resolution  


**Issue:**
```
Error: OperationNotPermitted
Message: This AWS account currently does not support creating load balancers
Service: Elastic Load Balancing v2
Operation: CreateLoadBalancer
```

**Verification Steps Completed:**
- ✅ Payment method added and verified
- ✅ Phone number verified (+44 7961152929)
- ✅ Email verified
- ✅ Contact information completed
- ✅ Infrastructure destroyed (no ongoing costs)


## Expected Flow After Resolution

Once AWS enables load balancer creation:
```bash
# Deploy infrastructure
terraform init
terraform plan -out=tfplan
terraform apply "tfplan"

# Get ALB DNS name from output
# Output: alb_dns_name = "day-5-app-alb-xxxxx.eu-west-2.elb.amazonaws.com"

# Wait 2-3 minutes for health checks
# Test in browser
http://day-5-app-alb-xxxxx.eu-west-2.elb.amazonaws.com

# Expected Result:
<h1>Hello from Private Server!</h1>
<p>Hostname: ip-10-0-10-x</p>
<p>Private IP: 10.0.10.x</p>
<p>OS: Ubuntu</p>
```

## Key Concepts Demonstrated
- **High Availability**: Multi-AZ deployment ensures service continues if one AZ fails
- **Security Layers**: Internet → ALB → Private instances (no direct internet access to backends)
- **Health Monitoring**: Automatic detection and routing around unhealthy instances
- **Scalability Ready**: Target group can easily accept additional EC2 instances
- **Infrastructure as Code**: Complete environment defined in Terraform
- **Professional Problem Handling**: Encountered limitation, created support case, documented issue
- **Cost Management**: Destroyed infrastructure while waiting to avoid unnecessary charges

## Production Readiness Notes

**What's Production-Ready:**
- ✅ Multi-AZ architecture for high availability
- ✅ Security group isolation (no direct internet access to backends)
- ✅ Health checks configured
- ✅ IAM roles for credential-less access
- ✅ Infrastructure as code

**What Could Be Added (Future Enhancements):**
- Auto Scaling Group for automatic capacity adjustment
- HTTPS listener with SSL/TLS certificate
- CloudWatch alarms for monitoring
- Multiple EC2 instances across AZs
- RDS database in private subnet
- Route 53 for custom domain
- WAF for application firewall

## Interview Talking Points

**Architecture Decision:** 
"I designed the ALB to sit in public subnets across two availability zones while keeping application servers in private subnets. This provides high availability and security - if one AZ fails, traffic automatically routes to the other, and backend servers are never directly exposed to the internet."

**Security Best Practice:**
"I configured security groups to only allow port 80 traffic from the ALB security group to private instances, not from 0.0.0.0/0. This implements defense in depth - even if someone discovers the private IP, they can't access it directly."

**Problem-Solving Experience:**
"When I encountered the AWS account limitation, I didn't stop - I created a professional support case, completed all verification steps, and documented the entire process. This mirrors real-world scenarios where you need to work with support teams and manage blockers."

**Cost Awareness:**
"While waiting for AWS support response, I destroyed all infrastructure to avoid unnecessary costs, particularly the NAT Gateway which costs ~$32/month. This shows I understand cloud cost management."