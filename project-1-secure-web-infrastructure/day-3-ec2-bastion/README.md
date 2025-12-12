# Day 3 - Bastion Host & Private EC2

## Requirements
- VPC CIDR: `10.0.0.0/16`
- Public subnet: `10.0.1.0/24` (eu-west-2a)
- Private subnet: `10.0.10.0/24` (eu-west-2a)
- Region: `eu-west-2` (London)
- SSH Key Pair: Manual creation in AWS Console
- Bastion Security Group (SSH from my IP only)
- Private Security Group (SSH from Bastion SG, HTTP from anywhere)
- Bastion EC2 instance (t2.micro, public subnet, public IP enabled)
- Private EC2 instance (t2.micro, private subnet, nginx installed via user data)

## Components Built
- Bastion Security Group with ingress port 22 from my IP
- Private Security Group with ingress port 22 from Bastion SG and port 80 from anywhere
- Bastion Host EC2 instance in public subnet
- Private Web Server EC2 instance in private subnet
- User data script for nginx installation
- Data source for Amazon Linux 2023 AMI lookup

## What I Built
Implemented a secure bastion host architecture for accessing private subnet resources. The bastion host sits in the public subnet as a "jump server" providing controlled SSH access to private instances. Private web server runs nginx and is only accessible via the bastion, following security best practices. This setup demonstrates the principle of defense in depth - no direct public access to application servers.

## Architecture Diagram
```
Internet (My IP: 31.104.176.250)
    │
    │ SSH (port 22)
    ▼
┌─────────────────────────────────────┐
│  Public Subnet (10.0.1.0/24)        │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Bastion Host               │    │
│  │  Public IP: 18.130.116.113  │    │
│  │  Private IP: 10.0.1.110     │    │
│  │  SG: bastion-sg             │    │
│  │  Allows: My IP → port 22    │    │
│  └──────────┬──────────────────┘    │
└─────────────┼───────────────────────┘
              │ SSH (port 22)
              ▼
┌─────────────────────────────────────┐
│  Private Subnet (10.0.10.0/24)      │
│                                     │
│  ┌─────────────────────────────┐    │
│  │  Private Web Server         │    │
│  │  Private IP: 10.0.10.209    │    │
│  │  SG: private-sg             │    │
│  │  Allows: Bastion SG → 22    │    │
│  │  Allows: Anyone → 80        │    │
│  │  Nginx: Running ✅          │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

## Files Created
- `main.tf` - Provider configuration only
- `network.tf` - VPC, subnets, IGW, NAT, route tables (from Day 2)
- `security.tf` - Bastion and Private Security Groups
- `compute.tf` - EC2 instances and AMI data source
- `variables.tf` - Variable definitions
- `outputs.tf` - Output values
- `terraform.tfvars.example` - Example values
- `terraform.tfvars` - Actual values (gitignored)

## Commands Used
```bash
# AWS Console: Created SSH key pair "akramul-key"
# Local: chmod 400 akramul-key.pem

terraform init
terraform fmt
terraform validate
terraform plan -out=tfplan
terraform apply "tfplan"

# Testing
ssh -i akramul-key.pem ubuntu@18.130.116.113
scp -i akramul-key.pem akramul-key.pem ubuntu@18.130.116.113:~/
ssh -i akramul-key.pem ubuntu@18.130.116.113
ssh -i ~/.ssh/akramul-key.pem ubuntu@10.0.10.209
curl http://localhost

terraform destroy  # when done testing
```

## What I Learned
- **Bastion Host pattern**: Jump server in public subnet provides secure access to private resources
- **Security Group references**: Using `security_groups = [aws_security_group.bastion_sg.id]` instead of CIDR blocks allows dynamic references that work even if IPs change
- **SSH key management**: Keys created in AWS Console can only be downloaded once; proper permission (chmod 400) is critical
- **Multi-hop SSH**: Local → Bastion → Private Server pattern requires key forwarding/copying
- **Security Group rules**: Ingress (who can enter), Egress (where can go) - egress typically "allow all" for internet access
- **File organization**: Splitting main.tf into network.tf, security.tf, compute.tf improves readability and maintenance
- **AMI differences**: Ubuntu uses `ubuntu` user, Amazon Linux uses `ec2-user`; package managers differ (apt vs yum)
- **User data scripts**: Automatically run on instance launch but must match the OS (yum for Amazon Linux, apt for Ubuntu)

## Issues I Faced
- **SSH permission error**: `akramul-key.pem` had 0755 permissions (too open) — fixed with `chmod 400`
- **SSH authentication failed**: Initially tried `ec2-user` but instances were Ubuntu (username: `ubuntu`)
- **Key pair mismatch confusion**: Variable name in terraform.tfvars vs actual AWS key pair name needed to match exactly
- **terraform validate errors**: Multiple resource naming mismatches between compute.tf and outputs.tf:
  - Used `bastion_host` in one place, `bastion` in another
  - Used `private_web` in outputs but `app_server` in compute
  - Referenced `aws_key_pair` resource that didn't exist
- **AMI variable issue**: Initially used hardcoded `var.ami_id` instead of data source lookup
- **Key not accessible on bastion**: Forgot to copy private key to bastion before attempting SSH to private instance
- **Wrong AMI**: Accidentally used Ubuntu AMI instead of Amazon Linux 2023 (variable vs data source confusion)

## Time Taken
~2-3 hours (Day 3)

## Testing Completed
✅ SSH from local machine to Bastion Host  
✅ Copied SSH key to Bastion  
✅ SSH from Bastion to Private Server  
✅ Verified nginx running on Private Server  
✅ Security Groups working correctly (port restrictions validated)  
✅ Multi-hop SSH connection successful