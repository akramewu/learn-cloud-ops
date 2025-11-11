# Week 3 – AWS VPC Networking (Explicit AZ version)

In this setup, Internet traffic first passes through the Internet Gateway (IGW) to a public Application Load Balancer (ALB) deployed in public subnets, where the ALB’s security group inspects and allows inbound traffic from the Internet. The ALB securely distributes requests only to EC2 instances running inside private subnets managed by an Auto Scaling Group (ASG) that uses a launch template to automatically increase or decrease instances based on demand. These EC2 instances are isolated from direct Internet access and can only receive traffic from the ALB’s security group, while using a NAT Gateway in the public subnet for safe outbound connections such as software updates or package downloads.

## Goal


## VPC Architecture


## Network Plan


## Terraform Structure

week2-vpc-networking/
│
├── main.tf                # provider + vpc.tf include
├── vpc.tf                 # vpc, igw, subnets, route tables
├── nat.tf                 # eip + nat gateway
├── security_groups.tf     # SGs for public/private EC2
├── ec2.tf                 # optional test instances
├── variables.tf
├── outputs.tf
└── diagram.png            # VPC architecture visual

## Concept Summary
                 |

## Verfication Checklist (Once Resources Created)


## Flashcards (15)

## Interview Tips



## Commands
```bash
terraform init
terraform plan -out=tfplan
terraform apply "tfplan"

## Destroy 
terraform destroy -auto-approve




