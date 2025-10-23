# 🌤️ Learn Cloud Ops — Terraform Backlog

This repository tracks my self-learning and hands-on practice on AWS using Terraform.

Each week focuses on one real-world cloud automation scenario — progressing from basic EC2 deployment to complete multi-tier infrastructure.

---

## 📅 Learning Backlog & Progress

| Week | Topic | Description | Status | GitHub Link |
|------|--------|-------------|---------|--------------|
| 1 | Terraform EC2 Demo | Provision t3.micro Ubuntu EC2, install Nginx via user_data | ✅ Completed | [Week 1 – EC2 Demo](https://github.com/akramewu/learn-cloud-ops/tree/main/week1-terraform-ec2) |
| 2 | VPC, Subnets, and Security Groups | Create custom VPC with public/private subnets and SGs | 🔄 In Progress | — |
| 3 | Auto Scaling & Load Balancer | Deploy web tier with ASG + ALB | ⏳ Planned | — |
| 4 | IAM Roles and Policies | Manage least-privilege IAM setup for Terraform-managed resources | ⏳ Planned | — |
| 5 | DynamoDB Integration | Use DynamoDB for backend state lock | ⏳ Planned | — |
| 6 | CI/CD Integration | Automate Terraform plan/apply using GitHub Actions | ⏳ Planned | — |

---

## 📘 Notes
- Each week folder includes:
  - Terraform code (`main.tf`, etc.)
  - `README.md` for explanation
  - Learning flashcards (in Markdown table)
- All projects are tested under AWS Free Tier.
