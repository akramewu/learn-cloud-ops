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
terraform plan
terraform apply
terraform destroy  # when done testing
```

## What I Learned
[Write your notes here after completing]

## Issues I Faced
[Write problems you encountered and how you solved them]

## Time Taken
Started: [Date/Time]
Completed: [Date/Time]
Total: [X hours]