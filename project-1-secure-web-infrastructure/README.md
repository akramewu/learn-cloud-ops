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