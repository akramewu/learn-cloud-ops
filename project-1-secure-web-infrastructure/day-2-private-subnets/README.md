# Day 2 - Private Subnets + NAT Gateway

## Requirements
- VPC CIDR: `10.0.0.0/16`
- Public subnet CIDR: `10.0.1.0/24` (eu-west-2a)
- Private subnet 1 CIDR: `10.0.10.0/24` (eu-west-2a)
- Private subnet 2 CIDR: `10.0.11.0/24` (eu-west-2b)
- Region: `eu-west-2` (London)
- NAT Gateway in public subnet with Elastic IP
- Enable DNS hostnames in VPC
- Tag everything properly (Name, Environment, Project)

## Components Built
- VPC with DNS hostnames enabled
- Internet Gateway
- Public subnet in eu-west-2a
- Private subnet in eu-west-2a
- Private subnet in eu-west-2b
- NAT Gateway with Elastic IP
- Public route table (0.0.0.0/0 → IGW)
- Private route table (0.0.0.0/0 → NAT)
- Route table associations

## What I Built
Multi-AZ VPC infrastructure with public and private subnets. Public subnet has direct internet access via IGW. Private subnets have outbound-only internet access via NAT Gateway. This is a typical production setup where web servers sit in public subnets and databases/backend services sit in private subnets.

## Architecture Diagram
```
INTERNET
                               │
                               ▼
                    ┌─────────────────────┐
                    │  Internet Gateway   │
                    └──────────┬──────────┘
                               │
┌──────────────────────────────┼──────────────────────────────┐
│  VPC: 10.0.0.0/16            │                              │
│                              │                              │
│  ┌───────────────────────────┼────────────────────────┐     │
│  │  eu-west-2a               │                        │     │
│  │                           ▼                        │     │
│  │    ┌──────────────────────────────────────┐        │     │
│  │    │  Public Subnet: 10.0.1.0/24          │        │     │
│  │    │                                      │        │     │
│  │    │    ┌──────────────────────┐          │        │     │
│  │    │    │  NAT GW + Elastic IP │          │        │     │
│  │    │    └──────────┬───────────┘          │        │     │
│  │    └───────────────┼──────────────────────┘        │     │
│  │                    │                               │     │
│  │                    ▼                               │     │
│  │    ┌──────────────────────────────────────┐        │     │
│  │    │  Private Subnet A: 10.0.10.0/24      │        │     │
│  │    └──────────────────────────────────────┘        │     │
│  └────────────────────────────────────────────────────┘     │
│                                                             │
│  ┌────────────────────────────────────────────────────┐     │
│  │  eu-west-2b                                        │     │
│  │                                                    │     │
│  │    ┌──────────────────────────────────────┐        │     │
│  │    │  Private Subnet B: 10.0.11.0/24      │        │     │
│  │    └──────────────────────────────────────┘        │     │
│  └────────────────────────────────────────────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘

Traffic Flow:
  Public Subnet  → IGW → Internet (direct)
  Private Subnet → NAT → IGW → Internet (outbound only)
```

## Files Created
- `main.tf` - Main infrastructure code
- `variables.tf` - Variable definitions
- `outputs.tf` - Output values
- `terraform.tfvars.example` - Example values
- `terraform.tfvars` - Actual values (gitignored)

## Commands Used
```bash
terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply "tfplan"
terraform destroy --auto-approve  # when done testing
```

## What I Learned
- Private subnets cannot directly access internet (no IGW route)
- NAT Gateway allows outbound-only internet access from private subnets
- NAT Gateway needs Elastic IP (static public IP)
- NAT Gateway must sit in public subnet
- Multi-AZ design: subnets spread across eu-west-2a and eu-west-2b for high availability
- `domain = "vpc"` replaced deprecated `vpc = true` for aws_eip
- Route table associations link routing rules to specific subnets

## Issues I Faced
- `terraform validate` error: "Reference to undeclared input variable" — renamed variable from `availability_zone` to `availability_zone_a` but forgot to update reference in main.tf
- `terraform validate` error: "Unsupported argument vpc = true" — aws_eip syntax changed, fixed by using `domain = "vpc"`
- `terraform plan` error: "Too many command line arguments" — wrong syntax `out=tfplan`, fixed to `-out=tfplan`

## Time Taken
~2-3 hours (Day 2)