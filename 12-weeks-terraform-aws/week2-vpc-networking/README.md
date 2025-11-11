# Week 2 – AWS VPC Networking (Explicit AZ version)

## Goal
Design a 2-AZ VPC:
- VPC 10.0.0.0/16
- 2 Public + 2 Private subnets
- Internet Gateway for public
- NAT Gateway for private
- Separate route tables

## VPC Architecture
<img width="653" height="793" alt="Screenshot 2025-11-06 at 17 03 49" src="https://github.com/user-attachments/assets/76c68d1c-e078-4e48-9aa9-304e2205df6f" />
<img width="647" height="663" alt="Screenshot 2025-11-06 at 16 57 55" src="https://github.com/user-attachments/assets/29fd6054-7e9f-4c53-822f-40742fdb03a6" />

## Network Plan
| Type | AZ | CIDR |
|------|----|------|
| Public A | eu-west-2a | 10.0.1.0/24 |
| Public B | eu-west-2b | 10.0.2.0/24 |
| Private A | eu-west-2a | 10.0.11.0/24 |
| Private B | eu-west-2b | 10.0.12.0/24 |

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

| Component                  | Description                                           | Interview Tip                                         |
| -------------------------- | ----------------------------------------------------- | ----------------------------------------------------- |
| **VPC**                    | Isolated AWS network; foundation for all resources    | “Your own private data center in AWS.”                |
| **Subnet**                 | Sub-division of a VPC; each in one AZ                 | “Public vs Private defined by route table, not name.” |
| **Internet Gateway (IGW)** | Enables inbound/outbound internet for public subnets  | “Acts like your building’s main door.”                |
| **NAT Gateway (NAT GW)**   | Allows private subnets to reach the internet outbound | “Private servers call out, but nobody calls in.”      |
| **Route Table**            | Controls destination of traffic                       | “Every subnet must have one route table.”             |
| **Availability Zone (AZ)** | Independent data center for high availability         | “Design across AZs → resilience.”                     |
| **CIDR Block**             | Defines IP range                                      | “10.0.0.0/16 gives 65,536 IPs.”                       |

## Verfication Checklist (Once Resources Created)

| Area              | What to Check                                 | Expected |
| ----------------- | --------------------------------------------- | -------- |
| **VPC**           | CIDR 10.0.0.0/16, DNS enabled                 | ✅        |
| **Subnets**       | 4 subnets (2 public + 2 private) across 2 AZs | ✅        |
| **IGW**           | Attached to VPC                               | ✅        |
| **NAT GW**        | In public subnet A, EIP assigned              | ✅        |
| **Route Tables**  | public → IGW; private → NAT GW                | ✅        |
| **EC2 (public)**  | Has public IP + Internet access               | ✅        |
| **EC2 (private)** | No public IP + Internet via NAT               | ✅        |

## Flashcards (15)

| #  | Question                                            | Answer                                                         |
| -- | --------------------------------------------------- | -------------------------------------------------------------- |
| 1  | What defines whether a subnet is public or private? | Its route table — if it has a route to IGW = public.           |
| 2  | Can a private subnet directly access the Internet?  | No — it uses NAT Gateway.                                      |
| 3  | Where must a NAT Gateway be deployed?               | In a public subnet with IGW access.                            |
| 4  | What’s the purpose of IGW?                          | Enables public subnets to reach Internet and be reachable.     |
| 5  | What’s the difference between SG & NACL?            | SG = stateful, instance-level; NACL = stateless, subnet-level. |
| 6  | How many route tables per subnet?                   | One active association.                                        |
| 7  | How do private EC2s access Yum updates?             | Through NAT Gateway (egress only).                             |
| 8  | What happens if NAT GW is in private subnet?        | It fails – no IGW access.                                      |
| 9  | How to save cost for NAT Gateway in dev?            | Use NAT instance or one NAT per AZ if multi-AZ.                |
| 10 | What command lists routes?                          | `aws ec2 describe-route-tables`                                |
| 11 | CIDR of 10.0.0.0/16 provides how many IPs?          | 65,536 IPs.                                                    |
| 12 | What is AZ and why use multiple?                    | Separate DCs for resilience and fault tolerance.               |
| 13 | Default route in public RT points to?               | Internet Gateway.                                              |
| 14 | Default route in private RT points to?              | NAT Gateway.                                                   |
| 15 | NAT GW vs IGW direction?                            | NAT GW = outbound only; IGW = in/out traffic.                  |

## Interview Tips

1. Explain the difference between a Public and Private Subnet.  
   - Public subnet: has a route to an Internet Gateway (IGW), allowing inbound and outbound Internet traffic.  
   - Private subnet: no direct route to IGW; can access the Internet only through a NAT Gateway or NAT Instance.

2. Why must a NAT Gateway be in a Public Subnet?  
   - The NAT Gateway itself needs Internet access to forward traffic from private subnets.  
   - It must be placed in a public subnet that has a route to the Internet Gateway.

3. How does a private EC2 instance get Internet access?  
   - The private instance sends traffic to its route table.  
   - The route table points 0.0.0.0/0 to the NAT Gateway.  
   - The NAT Gateway (in the public subnet) forwards it to the Internet Gateway.  
   - The return traffic comes back through the NAT Gateway.

4. What is the role of a Route Table?  
   - It defines where network traffic is directed within a VPC.  
   - Each subnet must be associated with exactly one route table.  
   - Example:  
     - Public subnets → 0.0.0.0/0 → IGW  
     - Private subnets → 0.0.0.0/0 → NAT Gateway

5. Can multiple subnets share one route table?  
   - Yes, multiple subnets can share a single route table if they need identical routing behavior.

6. What’s the maximum number of VPCs per region (default)?  
   - By default, 5 VPCs per region per account (can be increased via AWS Support).

7. How do you make a VPC highly available?  
   - Create subnets across multiple Availability Zones.  
   - Use multiple NAT Gateways (one per AZ).  
   - Deploy load balancers and EC2 instances across AZs.

8. What happens if a NAT Gateway fails?  
   - Private subnets lose outbound Internet access.  
   - To avoid this, deploy one NAT Gateway per Availability Zone.

9. What’s the difference between a NAT Gateway and a NAT Instance?

   | Feature | NAT Gateway | NAT Instance |
   |----------|--------------|---------------|
   | Managed by AWS | Yes | No |
   | Scaling | Automatic | Manual |
   | Availability | Highly available | Single instance |
   | Maintenance | Fully managed | User managed |
   | Cost | Higher | Lower (but more effort) |

10. What are best practices for subnet CIDR design?  
    - Plan non-overlapping CIDR ranges for each environment.  
    - Allocate a /16 CIDR to the VPC and /24 to each subnet.  
    - Separate public and private subnets per AZ.  
    - Reserve extra subnets for future growth.  
    - Avoid overlap with on-prem or peered VPCs.


## Commands
```bash
terraform init
terraform plan -out=tfplan
terraform apply "tfplan"

## Destroy 
terraform destroy -auto-approve




