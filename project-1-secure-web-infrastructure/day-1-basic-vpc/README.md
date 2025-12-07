# Day 1 - Basic VPC Setup

## Requirements
- VPC CIDR: `10.0.0.0/16`
- Public subnet CIDR: `10.0.1.0/24`
- Region: `eu-west-2` (London)
- Availability Zone: `eu-west-2a`
- Enable DNS hostnames in VPC
- Tag everything properly (Name, Environment, Project)

## Components to Build
- Provider configuration (region: eu-west-2)
- VPC resource
- Internet Gateway
- Public subnet in eu-west-2a
- Route table for public subnet
- Route table association

## What I Built
[Write here after you finish: describe what infrastructure you created]

## Architecture Diagram
```
[Draw simple text diagram or describe the setup]
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
terraform plan out=tfplan
terraform apply "tfplan"
terraform destroy  # when done testing
```

## What I Learned
- VPC is regional, subnets are per-AZ
- Internet Gateway sits at VPC edge, must be attached to VPC
- Route Table = traffic rules, Route Table Association = linking rules to a subnet
- 0.0.0.0/0 route to IGW makes a subnet "public"
- Terraform figures out resource order automatically via references (e.g., aws_vpc.main.id)

## Issues I Faced
- `terraform validate` errors — fixed missing required arguments
- `terraform fmt` — learned to run this before committing for consistent formatting

## Time Taken
~2-3 hours (Day 1)