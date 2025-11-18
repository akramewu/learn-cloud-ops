# Week 3 – AWS VPC Networking (Explicit AZ version)

In this setup, Internet traffic first passes through the Internet Gateway (IGW) to a public Application Load Balancer (ALB) deployed in public subnets, where the ALB’s security group inspects and allows inbound traffic from the Internet. The ALB securely distributes requests only to EC2 instances running inside private subnets managed by an Auto Scaling Group (ASG) that uses a launch template to automatically increase or decrease instances based on demand. These EC2 instances are isolated from direct Internet access and can only receive traffic from the ALB’s security group, while using a NAT Gateway in the public subnet for safe outbound connections such as software updates or package downloads.

## Goal


## ALB + ASG Architecture
  <img width="641" height="934" alt="Screenshot 2025-11-11 at 22 38 36" src="https://github.com/user-attachments/assets/461f2906-d353-4626-b090-d1ddb0876769" />
  <img width="630" height="935" alt="Screenshot 2025-11-11 at 22 40 08" src="https://github.com/user-attachments/assets/0a032549-0231-403f-9e05-f0d3cf7d2a44" />




## Network Plan


## Terraform Structure

week3-asg-private-subnets/
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


## Flashcards (15)

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

📡 Real-World Architecture Pattern (not implemented here because of limited ALB permit)
VPC & Subnets → SG → ALB → Target Group → Listener → ASG / ECS / EKS targets

            INTERNET
                ↓
      ┌─────────────────┐
      │  ALB Security   │  (Allows 80/443)
      └─────────────────┘
                ↓
        ┌────────────┐
        │    ALB     │  (Public Subnets)
        └────────────┘
                ↓
       ┌────────────────┐
       │ Listener : 80  │  (Incoming rule)
       └────────────────┘
                ↓
     ┌─────────────────────┐
     │   Target Group      │  (Health Checks)
     └─────────────────────┘
                ↓
   ┌──────────────────────────┐
   │   EC2 in Private Subnet  │
   └──────────────────────────┘



## Commands
```bash
terraform init
terraform plan -out=tfplan
terraform apply "tfplan"

## Destroy 
terraform destroy -auto-approve




