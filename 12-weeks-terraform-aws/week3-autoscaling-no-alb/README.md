# Week 3 – Auto Scaling Group in Private Subnets (ALB Disabled)

This week focuses on deploying a production-style compute layer using Terraform.
We build an Auto Scaling Group (ASG) inside private subnets, with Internet access provided through a NAT Gateway.

The ALB module is fully implemented but disabled due to AWS free-tier restrictions, which blocked ALB creation.
This lets you learn the full architecture while still deploying the parts your account supports.

🧩 Concept Summary

| **Component**              | **Description**                                          | **Interview Tip**                                    |
| -------------------------- | -------------------------------------------------------- | ---------------------------------------------------- |
| **VPC**                    | Your isolated private network in AWS                     | “Think of it as your AWS data center.”               |
| **Subnet**                 | Subdivision of VPC tied to one AZ                        | “Public vs Private is defined by the *route table*.” |
| **Internet Gateway (IGW)** | Enables public subnets to communicate with the Internet  | “Acts like your building’s main door.”               |
| **NAT Gateway (NAT GW)**   | Allows private subnets to reach Internet *outbound only* | “Private servers call out, but nobody calls in.”     |
| **Route Table**            | Determines where traffic goes                            | “Every subnet must have one route table.”            |
| **Availability Zone (AZ)** | Independent DC for high availability                     | “Always use 2+ AZ for resilience.”                   |
| **CIDR Block**             | Defines IP range                                         | `10.0.0.0/16` = **65,536 IPs**                       |


## ALB + ASG Architecture (Real World Pattern) 
  <img width="641" height="934" alt="Screenshot 2025-11-11 at 22 38 36" src="https://github.com/user-attachments/assets/461f2906-d353-4626-b090-d1ddb0876769" />
  <img width="630" height="935" alt="Screenshot 2025-11-11 at 22 40 08" src="https://github.com/user-attachments/assets/0a032549-0231-403f-9e05-f0d3cf7d2a44" />

  <img width="863" height="914" alt="Screenshot 2025-11-18 at 19 23 22" src="https://github.com/user-attachments/assets/a92e6bcb-3e63-47a8-9780-3abcb89f8212" />
  <img width="863" height="918" alt="Screenshot 2025-11-18 at 19 24 02" src="https://github.com/user-attachments/assets/bd9b6a70-781a-4bd3-bc37-da75053e97d9" />


## No ALB + ASG Architecture
<img width="861" height="915" alt="Screenshot 2025-11-18 at 19 48 20" src="https://github.com/user-attachments/assets/8c20c8d5-71e0-4076-8958-afa9f136a10d" />
<img width="861" height="915" alt="Screenshot 2025-11-18 at 19 48 31" src="https://github.com/user-attachments/assets/b0a5bcc1-f329-4989-8123-4409883f323f" />
<img width="861" height="323" alt="Screenshot 2025-11-18 at 19 48 41" src="https://github.com/user-attachments/assets/5e80bc95-5ab3-4bc7-8e39-50b35dd78183" />



## Network Plan


## Terraform Structure

```text
week3-autoscaling-no-alb/
│
├── main.tf                     # Root module orchestrating all submodules
├── variables.tf                # Root input variables
├── outputs.tf                  # Root outputs
├── terraform.tfvars            # Environment variables
│
├── networking/                 # VPC + Subnets + Routing
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
├── loadbalancer/               # ALB module (DISABLED)
│   ├── variables.tf
│   ├── 01-alb-sg.tf
│   ├── 02-alb.tf
│   ├── 03-target-group.tf
│   ├── 04-listener.tf
│   └── outputs.tf
│
└── compute/                    # ASG + Launch Template
    ├── variables.tf
    ├── 01-asg-sg.tf            # ASG Security Group (no ALB)
    ├── 02-launch-template.tf   # EC2 launch template
    └── 03-autoscaling.tf       # ASG in private subnets
        outputs.tf
```


                 
🧪 Verification Checklist (After Terraform Apply)

| **Area**                | **What to Verify**                            | **Expected** |
| ----------------------- | --------------------------------------------- | ------------ |
| **VPC**                 | CIDR = `10.0.0.0/16`, DNS hostnames enabled   | ✅            |
| **Subnets**             | 4 subnets (2 public + 2 private across 2 AZs) | ✅            |
| **IGW**                 | Attached to VPC                               | ✅            |
| **NAT Gateway**         | In public subnet A, has Elastic IP            | ✅            |
| **Public Route Table**  | `0.0.0.0/0 → IGW`                             | ✅            |
| **Private Route Table** | `0.0.0.0/0 → NAT Gateway`                     | ✅            |
| **ASG EC2 Instances**   | Private subnet only, no public IP             | ✅            |
| **Outbound Internet**   | `sudo apt update` works in EC2 (via NAT)      | ✅            |



🧠 Flashcards (15 High-Value Questions)
| #      | **Question**                                   | **Answer**                                                         |
| ------ | ---------------------------------------------- | ------------------------------------------------------------------ |
| **1**  | What makes a subnet public or private?         | Its **route table**. If it routes to IGW → public.                 |
| **2**  | Can a private subnet access Internet directly? | ❌ No — it uses NAT Gateway.                                        |
| **3**  | Where must NAT Gateway be deployed?            | In a **public subnet** with IGW access.                            |
| **4**  | Purpose of IGW?                                | Enable inbound/outbound Internet for public subnets.               |
| **5**  | SG vs NACL?                                    | SG = stateful, instance-level. NACL = stateless, subnet-level.     |
| **6**  | How many RTs per subnet?                       | Only **one** active association.                                   |
| **7**  | How do private EC2s install updates?           | Through NAT Gateway (egress only).                                 |
| **8**  | What if NAT is placed in private subnet?       | It fails — no IGW access.                                          |
| **9**  | How to save NAT cost in dev?                   | Use NAT Instance or one NAT per region (not recommended for prod). |
| **10** | Command to list RTs?                           | `aws ec2 describe-route-tables`                                    |
| **11** | How many IPs in `/16`?                         | 65,536 IPs.                                                        |
| **12** | Why 2 AZs?                                     | High availability and fault tolerance.                             |
| **13** | Default public RT target?                      | Internet Gateway.                                                  |
| **14** | Default private RT target?                     | NAT Gateway.                                                       |
| **15** | IGW vs NAT GW direction?                       | IGW = inbound+outbound; NAT = outbound only.                       |


## Interview Tips
```text

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


1. Explain Public vs Private Subnet

Public subnet routes to IGW

Private subnet routes to NAT Gateway

Name doesn't matter — route table decides public/private

2. Why NAT Gateway Must Be in Public Subnet

Because NAT needs a public IP + IGW to forward outbound traffic.

3. Why Application Is Not Public

Because EC2 in private subnet has:

No public IP

No IGW

No inbound path

Only outbound Internet through NAT.

4. Perfect Interview Explanation

“My EC2 instances run inside private subnets. They scale via ASG and use NAT Gateway for outbound updates.
They are not publicly accessible because ALB is disabled; ALB normally sits in public subnets and forwards traffic to private EC2s.
This is the recommended production architecture pattern.”
```

## Commands
```bash
terraform init
terraform plan -out=tfplan
terraform apply "tfplan"

## Destroy 
terraform destroy -auto-approve




