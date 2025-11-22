🏗️ AWS VPC Networking – Terraform Workflow (Production-Ready Guide)

This guide summarizes the proper order to build AWS networking using Terraform:
VPC → IGW → Subnets → Route Tables → NAT Gateway → Security → Compute → Database.

It follows real-world architecture patterns used across modern DevOps teams.

```text
| Step | Resource                      | Description                           | Why                                    |
| ---- | ----------------------------- | ------------------------------------- | -------------------------------------- |
| 1    | **VPC**                       | Create network boundary               | Everything depends on the VPC          |
| 2    | **IGW**                       | Internet access for public subnets    | Required for public connectivity       |
| 3    | **Public Subnets**            | Must auto-assign public IPs           | Required for ALB/bastion/NAT           |
| 4    | **Public Route Table**        | IGW route: `0.0.0.0/0 → igw`          | Outbound internet for public           |
| 5    | **Associate Public RT**       | Map route table ↔ subnet              | Routes won’t apply without association |
| 6    | **Private Subnets**           | No public IP                          | For EC2 app, DB, EKS                   |
| 7    | **NAT Gateway + EIP**         | Outbound internet for private subnets | Private EC2 needs updates, API calls   |
| 8    | **Private Route Table**       | `0.0.0.0/0 → NAT`                     | Outbound internet path                 |
| 9    | **Associate Private RT**      | Map to private subnet                 | Apply NAT routing logic                |
| 10   | **Security Groups**           | SGs for ALB/App/DB/Bastion            | Network boundary at EC2 level          |
| 11   | **Bastion Host (Optional)**   | Public EC2 for SSH jump               | Internal troubleshooting               |
| 12   | **Application EC2 (Private)** | Backend servers private               | Best practice security                 |
| 13   | **ALB (Public)**              | Fronts all internet traffic           | Routes to private EC2                  |
| 14   | **RDS Database (Private)**    | No public access ever                 | Critical security requirement          |



📘 Why This Order? (Short Explanation)
✔ VPC must exist first

Everything (subnets, IGW, routes, EC2) depends on it.

✔ IGW must be created before public routing

Without IGW, you cannot create 0.0.0.0/0 routes.

✔ Subnets must exist before routes

Route tables need subnet IDs for association.

✔ NAT Gateway requires an EIP in a public subnet

Because NAT must be reachable from the internet.

✔ Private subnets must use NAT for outbound

Otherwise EC2 cannot install packages or talk to AWS APIs.

✔ ALB in public → EC2 in private

This is the industry-standard 2-tier security layout.

✔ Database always stays private

A database must never have direct public access.


Terraform Folder Structure (Recommended)

terraform-project/
├── main.tf
├── provider.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars
│
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │
│   ├── subnets/
│   ├── route-tables/
│   ├── nat/
│   ├── security-groups/
│   ├── ec2/
│   └── rds/
│
└── diagrams/
    └── architecture.png (optional)


Architecture Diagram (Public + Private Subnets)


                           ┌────────────────────────┐
                           │        Internet        │
                           └────────────▲───────────┘
                                        │
                      Public Subnets    │
               ┌────────────────────────┴────────────────────────┐
               │                    ALB                          │
               │            (Public, has Public IP)              │
               └───────────────▲─────────┬────────────▲─────────┘
                               │         │            │
                       (HTTP/HTTPS)     │            │
                               │         │            │
                     ┌─────────┘         │            └──────────┐
                     │                   │                       │
                     │            ┌──────┴──────┐          NAT Gateway
                     │            │ Bastion Host│          (Public)
                     │            │ (Public IP) │               ▲
                     │            └──────▲──────┘               │
                     │                   │ (SSH)                │
                     │                   │                      │
     Private Subnets │       ┌───────────┴──────────┐           │
 ┌───────────────────┴───────►    EC2 App Server    │───────────┘
 │                            │   (Private Only)     │
 │                            └────────────▲─────────┘
 │                                         │
 │                                         │ (DB Connection)
 │                            ┌────────────┴───────────┐
 │                            │         RDS DB          │
 │                            │     (Private Only)      │
 │                            └─────────────────────────┘
 │
 └───────────────────────────────────────────────────────────────┘


Terraform resources ALB needs

| Terraform Resource               | Purpose                 |
| -------------------------------- | ----------------------- |
| `aws_lb`                         | Create the ALB itself   |
| `aws_security_group`             | ALB security group      |
| `aws_lb_target_group`            | Where ALB sends traffic |
| `aws_lb_listener`                | HTTP/HTTPS listener     |
| `aws_lb_listener_rule`           | Optional routing rules  |
| `aws_lb_target_group_attachment` | Attach EC2/ECS targets  |


One-Line Memory Trick (Super Useful)

VPC
→ IGW
→ Public Subnets
→ Public Route Table + Assoc
→ Private Subnets
→ NAT + EIP
→ Private Route Table + Assoc
→ Security Groups
→ Bastion (public)
→ App EC2 (private)
→ ALB (public → private)
→ RDS (private)


More Clear Version
VPC
 ├── IGW
 ├── Public Subnets
 │    └── Public Route Table + Association
 ├── NAT + EIP
 ├── Private Subnets
 │    └── Private Route Table + Association
 ├── Security Groups
 │    ├── ALB SG
 │    ├── App SG
 │    ├── DB SG
 │    └── Bastion SG
 ├── Bastion Host (Optional)
 ├── ALB
 │    └── ALB Listener
 ├── Target Group
 │    └── Target Group Attachment
 ├── App Servers (EC2/ASG)
 └── RDS


```
