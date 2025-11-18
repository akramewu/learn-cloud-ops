# learn-cloud-ops
cloud learning

# terraform 


# Roadmap (VPC → EC2 → DynamoDB → IAM → Autoscaling → CI/CD).

# 12-Week CloudOps & Terraform Learning Roadmap

| Week | Focus Area                   | Key Deliverable / Mini-Project                                               | Status |
|------|------------------------------|-------------------------------------------------------------------------------|--------|
| 1    | Terraform Basics + EC2       | Launch EC2 with user_data automation                                         | ✅ Done |
| 2    | VPC Networking               | Multi-AZ VPC with IGW, NAT, Subnets, Route Tables                            | ✅ Done |
| 3    | Load Balancing & HA         | Auto Scaling Group (EC2 in private subnets), ALB module prepared (disabled) | ✅ Done (No-ALB Mode) |
| 4    | Security & IAM               | IAM roles, instance profiles, least-privilege design                        | 🔜 Next |
| 5    | Storage & Databases          | S3 + DynamoDB introduction, Terraform lifecycle rules                       | 🔜 Planned |
| 6    | CI/CD with Terraform         | GitHub Actions / Jenkins pipeline to deploy Terraform                       | 🔜 Planned |
| 7    | Kubernetes on AWS (EKS)      | Create EKS cluster + node groups using Terraform                            | 🔜 Planned |
| 8    | Containers & ECS             | Deploy a containerized app on ECS (Fargate/EC2)                             | 🔜 Planned |
| 9    | Monitoring & Logging         | CloudWatch alarms, metrics, log groups, Terraform integration               | 🔜 Planned |
| 10   | Secrets & Network Security   | SSM Parameter Store, KMS, SGs, NACLs                                        | 🔜 Planned |
| 11   | Multi-Cloud / Advanced IaC   | Add Azure or GCP Terraform module; hybrid design                            | 🔜 Planned |
| 12   | Final Capstone Project       | Full 3-tier web app + CI/CD, VPC, EKS/ECS, monitoring, README showcase      | 🔜 Planned |

## Project Folder
```text
learn-cloud-ops/
├── week1-terraform-ec2/
├── week2-vpc-networking/
├── week3-autoscaling-no-alb/
├── week4-iam-security/
├── week5-s3-dynamodb/
├── week6-cicd-terraform/
├── week7-eks-cluster/
├── week8-ecs-fargate/
├── week9-cloudwatch-monitoring/
├── week10-kms-ssm/
├── week11-multicloud/
└── week12-final-project/
```
