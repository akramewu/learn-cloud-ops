# Week 1 – Terraform AWS EC2 Demo

This project deploys a **free-tier t3.micro EC2** running Ubuntu 22.04 LTS using Terraform.  
At boot, it installs **Nginx** and serves a simple HTML page.

## Usage
```bash
terraform init
terraform plan -out=tfplan
terraform apply "tfplan"

## Cleanup
terraform destroy -auto-approve

# Visit http://<public_ip>

# Files
main.tf – EC2 resource
variables.tf – inputs
outputs.tf – public IP & DNS
provider.tf, versions.tf – provider setup
terraform.tfvars – sample inputs

# Learning & Flashcards


| #  | Question                              | Answer                                                              |
| -- | ------------------------------------- | ------------------------------------------------------------------- |
| 1  | What is Terraform used for?           | Infrastructure as Code (provision and manage cloud resources).      |
| 2  | What’s the workflow?                  | Init → Plan → Apply → Destroy.                                      |
| 3  | What is `provider`?                   | Plugin that lets Terraform manage a specific API (AWS, Azure …).    |
| 4  | What is a Terraform state file?       | Stores real-world resource mapping to track drift.                  |
| 5  | What happens on `terraform plan`?     | Compares desired vs current state, shows changes.                   |
| 6  | Difference between `var` and `local`? | Variables = external inputs; locals = internal computed values.     |
| 7  | AWS region vs AZ?                     | Region = geographic area; AZ = isolated datacenter inside a region. |
| 8  | Public vs Private subnet?             | Public has route to IGW; private does not.                          |
| 9  | Default VPC security rules?           | Inbound allow from same SG; outbound allow all.                     |
| 10 | What’s user_data in Terraform EC2?    | Script run at instance boot.                                        |
| 11 | How to view Terraform resources?      | `terraform state list`                                              |
| 12 | How to SSH into EC2?                  | `ssh -i <key>.pem ubuntu@<public_ip>`                               |
| 13 | What’s AWS Free Tier limit for EC2?   | 750 hrs/month of t2.micro for 12 months.                            |
| 14 | Difference between SG and NACL?       | SG = stateful, instance-level; NACL = stateless, subnet-level.      |
| 15 | Terraform backend purpose?            | Store remote state (S3 + DynamoDB for lock).                        |
| 16 | How to output a value?                | `output "name" { value = … }`                                       |
| 17 | Command to format files?              | `terraform fmt`                                                     |
| 18 | Command to validate syntax?           | `terraform validate`                                                |
| 19 | How to destroy infra safely?          | `terraform destroy`                                                 |
| 20 | Main benefit of IaC?                  | Consistency, repeatability, and version control.                    |
