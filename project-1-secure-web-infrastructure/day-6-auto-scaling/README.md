# Day 6 - Auto Scaling Group

## Requirements
- VPC CIDR: `10.0.0.0/16`
- Public subnets: `10.0.1.0/24` (eu-west-2a), `10.0.2.0/24` (eu-west-2b)
- Private subnets: `10.0.10.0/24` (eu-west-2a), `10.0.11.0/24` (eu-west-2b)
- Region: `eu-west-2` (London)
- Launch Template for EC2 configuration
- Auto Scaling Group (Min: 1, Max: 3, Desired: 2)
- Scaling Policies (CPU-based)
- CloudWatch Alarms for monitoring
- Multi-AZ deployment

## Components Built
- Launch Template (EC2 blueprint with nginx user data)
- Auto Scaling Group with target group integration
- Scale OUT Policy (CPU > 70%)
- Scale IN Policy (CPU < 30%)
- CloudWatch High CPU Alarm (triggers scale out)
- CloudWatch Low CPU Alarm (triggers scale in)
- Health checks via ELB
- Automatic target group registration

## What I Built
Designed complete Auto Scaling architecture to automatically manage EC2 instances based on demand. The Auto Scaling Group monitors CPU utilization through CloudWatch and dynamically adds or removes instances to maintain optimal performance while minimizing costs. Instances are launched from a Launch Template containing nginx configuration and automatically registered to the Application Load Balancer's target group.

## Architecture Diagram
```
Users/Traffic
    ↓
Application Load Balancer (Multi-AZ)
    ↓
Target Group (Port 80)
    ↓
┌─────────────────────────────────────────────┐
│  Auto Scaling Group                         │
│  Min: 1, Max: 3, Desired: 2                 │
│                                             │
│  Launch Template (Blueprint):               │
│  - AMI: Ubuntu                              │
│  - Instance Type: t2.micro                  │
│  - Security Group: private-sg               │
│  - IAM Role: ec2_instance_profile           │
│  - User Data: nginx install                 │
│                                             │
│  ┌──────────────────────────────────────┐   │
│  │ Private Subnet A (eu-west-2a)        │   │
│  │  ┌────────────┐  ┌────────────┐      │   │
│  │  │ EC2-1      │  │ EC2-2      │      │   │
│  │  │ nginx      │  │ nginx      │      │   │
│  │  └────────────┘  └────────────┘      │   │
│  └──────────────────────────────────────┘   │
│                                             │
│  ┌──────────────────────────────────────┐   │
│  │ Private Subnet B (eu-west-2b)        │   │
│  │  (Standby for scaling)               │   │
│  └──────────────────────────────────────┘   │
│                                             │
│  CloudWatch Monitoring:                     │
│  ┌────────────────┐  ┌────────────────┐    │
│  │ High CPU Alarm │  │ Low CPU Alarm  │    │
│  │ CPU > 70%      │  │ CPU < 30%      │    │
│  │ → Scale OUT    │  │ → Scale IN     │    │
│  └────────────────┘  └────────────────┘    │
└─────────────────────────────────────────────┘

Scaling Flow:
- CPU > 70% (5 min) → CloudWatch Alarm → Scale OUT → Add 1 instance
- CPU < 30% (5 min) → CloudWatch Alarm → Scale IN → Remove 1 instance
- Health Check: ELB checks every 30s
- Grace Period: 5 minutes for new instances
```

## Files Created/Modified
- `launch_template.tf` - Launch Template + Auto Scaling Group
- `scaling_policies.tf` - Scaling Policies + CloudWatch Alarms
- `compute.tf` - Removed manual EC2 instance (ASG manages instances)
- `alb.tf` - Removed manual target group attachment (ASG auto-registers)
- `outputs.tf` - Added ASG and Launch Template outputs
- Other files remain same (network.tf, security.tf, iam.tf, s3.tf)

## Commands Used
```bash
# Setup
cd project-1-secure-web-infrastructure
cp -r day-5-load-balancer day-6-auto-scaling
cd day-6-auto-scaling

# Terraform workflow
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply "tfplan"  # Failed due to account limitations

# Cleanup
terraform destroy  # Successfully destroyed all resources
```

## What I Learned
- **Auto Scaling Group (ASG)**: Automatically manages EC2 instance count based on demand
- **Launch Template**: Blueprint for new instances (replaces Launch Configuration)
- **Scaling Policies**: Rules that define when to add/remove instances
- **CloudWatch Alarms**: Monitor metrics and trigger scaling actions
- **Target Tracking**: ASG can automatically scale based on target metric values
- **Health Checks**: ELB health checks ensure only healthy instances receive traffic
- **Grace Period**: Time to wait before checking health of newly launched instances
- **Multi-AZ Deployment**: Instances distributed across availability zones for resilience
- **Automatic Registration**: ASG automatically registers/deregisters instances from target groups
- **Cost Optimization**: Scale down during low traffic to save costs
- **High Availability**: Automatically replace failed instances

## Issues I Faced

### Issue 1: AWS Account Limitation - ALB Creation Blocked
```
Error: OperationNotPermitted
Message: This AWS account currently does not support creating load balancers
Service: Elastic Load Balancing v2
```
**Status:** Same as Day 5 - AWS Support Case #176615986800533 pending

### Issue 2: Auto Scaling Group Free Tier Error
```
Error: waiting for Auto Scaling Group capacity satisfied
Message: The specified instance type is not eligible for Free Tier
Details: Launching EC2 instance failed
```
**Root Cause:** Account free tier limitations or expired free tier eligibility

**Action Taken:**
- Destroyed all infrastructure to avoid costs
- Documented complete architecture and code
- Awaiting AWS Support resolution for account verification

### Issue 3: Name Mismatch in outputs.tf
```
Error: Reference to undeclared resource
aws_launch_template.app_template vs app_launch_template
```
**Fix:** Updated outputs.tf to match actual resource name

## Time Taken
~2-3 hours (Day 6 - Architecture & Code)

## Testing Status
❌ **Deployment Blocked** - Unable to test due to AWS account limitations  
✅ **Code Validated** - terraform validate successful  
✅ **Architecture Designed** - Complete infrastructure code ready  
⏳ **Pending** - Awaiting AWS Support case resolution  

## AWS Support Case Status

**Case ID:** 176615986800533  
**Created:** 2025-12-19  
**Status:** Unassigned (Awaiting human agent)  

**Issues:**
1. ALB creation blocked (OperationNotPermitted)
2. Free Tier eligibility errors
3. Account verification pending

**Timeline:**
- Case submitted: 2025-12-19
- Expected resolution: 24-48 hours

## Expected Flow After Resolution

Once AWS enables load balancer creation and resolves free tier issues:
```bash
# Deploy infrastructure
terraform init
terraform plan -out=tfplan
terraform apply "tfplan"

# Verify ASG
aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names day-6-asg

# Check running instances
aws ec2 describe-instances --filters "Name=tag:Name,Values=day-6-asg-instance"

# Get ALB DNS
terraform output alb_dns_name

# Test in browser
http://<alb-dns-name>

# Simulate high CPU to test scaling
# SSH to instance: stress --cpu 8 --timeout 300s
# Watch ASG scale out: aws autoscaling describe-auto-scaling-activities

# Expected Result:
# - Initial: 2 instances running
# - High CPU: Scales to 3 instances
# - Low CPU: Scales back to 1 instance
# - Health checks working
# - Traffic distributed across instances
```

## Key Concepts Demonstrated
- **Dynamic Scaling**: Automatic instance management based on demand
- **Cost Optimization**: Scale down during low traffic periods
- **High Availability**: Multi-AZ deployment with automatic failover
- **Infrastructure as Code**: Complete environment defined in Terraform
- **Monitoring & Alerting**: CloudWatch integration for proactive scaling
- **Zero-Touch Operations**: No manual intervention required
- **Self-Healing**: Automatic replacement of unhealthy instances

## Auto Scaling vs Manual (Day 5 Comparison)

**Day 5 (Static):**
- ❌ Fixed 1 instance
- ❌ Manual scaling required
- ❌ No automatic failover
- ❌ Fixed costs regardless of load

**Day 6 (Dynamic):**
- ✅ Auto scales 1-3 instances
- ✅ Responds to demand automatically
- ✅ Replaces failed instances
- ✅ Cost-efficient (pays for what you use)

## Production Readiness Notes

**What's Production-Ready:**
- ✅ Multi-AZ Auto Scaling Group
- ✅ CPU-based scaling policies
- ✅ Health checks configured
- ✅ Automatic instance replacement
- ✅ Load balancer integration
- ✅ Infrastructure as code

**What Could Be Added:**
- Multiple scaling metrics (memory, network)
- Scheduled scaling for predictable patterns
- Step scaling policies for gradual scaling
- SNS notifications for scaling events
- Enhanced monitoring dashboards
- Predictive scaling using ML

## Interview Talking Points

**Auto Scaling Value:**
"I implemented Auto Scaling to automatically manage EC2 instances based on CPU utilization. When traffic increases and CPU exceeds 70%, CloudWatch triggers the scale-out policy to add instances. During low traffic periods below 30% CPU, instances are removed to optimize costs. This ensures the application can handle traffic spikes while minimizing infrastructure expenses."

**Architecture Decision:**
"I configured the ASG with min 1, max 3, and desired 2 instances across two availability zones. This provides baseline capacity for normal operation, headroom for traffic spikes, and high availability through multi-AZ deployment. The 5-minute grace period allows new instances to fully initialize before receiving traffic."

**Cost Optimization:**
"Unlike static infrastructure that runs continuously regardless of load, Auto Scaling reduces costs by scaling down during low-traffic periods. With proper monitoring and scaling policies, you only pay for the capacity you actually need."

**Real-World Application:**
"This pattern is essential for production workloads with variable traffic - e-commerce sites during sales, news sites during breaking news, or any application with daily/weekly traffic patterns. It's a fundamental AWS best practice for building scalable, cost-effective infrastructure."