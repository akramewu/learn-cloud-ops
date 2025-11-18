# Week 3 – Auto Scaling Group in Private Subnets (ALB Disabled)

This week focuses on deploying a production-style compute layer using Terraform.
We build an Auto Scaling Group (ASG) inside private subnets, with Internet access provided through a NAT Gateway.

The ALB module is fully implemented but disabled due to AWS free-tier restrictions, which blocked ALB creation.
This lets you learn the full architecture while still deploying the parts your account supports.

## Goal


## ALB + ASG Architecture
  <img width="641" height="934" alt="Screenshot 2025-11-11 at 22 38 36" src="https://github.com/user-attachments/assets/461f2906-d353-4626-b090-d1ddb0876769" />
  <img width="630" height="935" alt="Screenshot 2025-11-11 at 22 40 08" src="https://github.com/user-attachments/assets/0a032549-0231-403f-9e05-f0d3cf7d2a44" />


## No ALB + ASG Architecture


## Network Plan


## Terraform Structure

week3-autoscaling-no-alb/
│
├── main.tf                 # Root module orchestrating all submodules
├── variables.tf            # Root input variables
├── outputs.tf              # Root outputs
├── terraform.tfvars        # Environment-specific variable values
│
├── networking/             # VPC + Subnets + Routing
│   ├── variables.tf
│   ├── 01-vpc.tf
│   ├── 02-internet-gateway.tf
│   ├── 03-public-subnets.tf
│   ├── 04-private-subnets.tf
│   ├── 05-public-route-table.tf
│   ├── 06-nat-gateway.tf
│   ├── 07-private-route-table.tf
│   └── outputs.tf
│
├── loadbalancer/           # ALB module (DISABLED for now, account restricted)
│   ├── variables.tf
│   ├── 01-alb-sg.tf
│   ├── 02-alb.tf
│   ├── 03-target-group.tf
│   ├── 04-listener.tf
│   └── outputs.tf
│
└── compute/                # Auto Scaling Group + EC2 Launch Template
    ├── variables.tf
    ├── 01-asg-sg.tf         # ASG Security Group (NO ALB MODE)
    ├── 02-launch-template.tf
    ├── 03-autoscaling.tf    # ASG → in private subnets
    └── outputs.tf


## Concept Summary
                 |

## Verfication Checklist (Once Resources Created)


## Flashcards

## Interview Tips

📌 Why the Application Is Not Publicly Accessible (No ALB)

In this project, the Auto Scaling Group (ASG) launches EC2 instances inside private subnets.
Without an Application Load Balancer (ALB), these instances cannot be accessed from the Internet.

🚫 Private EC2 Instances Cannot Receive External Traffic

Private EC2 instances:

Have no public IP address

Cannot accept inbound Internet traffic

Cannot be reached directly from outside the VPC

Depend on ALB or NLB to expose the application

As a result, even though the ASG and EC2 launch correctly, the application remains internal-only.



## Commands
```bash
terraform init
terraform plan -out=tfplan
terraform apply "tfplan"

## Destroy 
terraform destroy -auto-approve




