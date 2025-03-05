# learn-cloud-ops
cloud learning

# AWS Infrastructure with Terraform - Step-by-Step Learning Plan
Step 1: Preparation
        Install Terraform
        Set Up AWS CLI & Configure Credentials
        Create a Basic Terraform Configuration
        Create a main.tf file

Step 2: VPC, Subnets, and Security Groups (Networking)
Step 3: EC2 Instances (Compute)
Step 4: DynamoDB (Database)
Step 5: IAM Users and Roles (Security)
Step 6: Autoscaling and Load Balancing
Step 7: CI/CD with Terraform (not implemented yet will be)

# Project Structure 
```
terraform-project/
│
├── provider.tf          # AWS provider configuration
├── variables.tf         # Variable definitions
├── s3.tf                # S3 bucket configuration
├── vpc.tf               # VPC, Subnet, Internet Gateway, Route Table configurations
├── security_group.tf    # Security Group configuration
├── ec2.tf               # EC2 Instance and Key Pair configurations
├── dynamodb.tf          # DynamoDB Table configuration
├── iam.tf               # IAM Roles, Policies, and Users
├── load_balancer.tf     # Application Load Balancer configuration
├── auto_scaling.tf      # Launch Template and Auto Scaling Group configurations
└── outputs.tf           # Optional: Output values
```

# Architecture Diagram 

![AWS Architecture](https://raw.githubusercontent.com/akramewu/learn-cloud-ops/main/aws-terraform-project/images/aws-architecture-diagram.svg)

Key Improvements:
1. Added VPC Endpoint for DynamoDB (purple box)
2. Created direct connections from both Public and Private EC2 to the VPC Endpoint
3. VPC Endpoint connects to DynamoDB without going through the Internet Gateway

Benefits of VPC Endpoint:
- Private network access to DynamoDB
- No need for NAT Gateway or Internet Gateway
- Improved security
- Potentially lower data transfer costs

Terraform Changes:
1. Added `aws_vpc_endpoint` resource for DynamoDB
2. Created a private route table
3. Added route table association for the private subnet

Additional Recommendations:
1. Consider adding a NAT Gateway if private instances need internet access
2. Implement stricter IAM policies
3. Use VPC Flow Logs for monitoring

# Comprehensive Terraform Infrastructure Configuration Guide

## 1. `provider.tf`
```hcl
provider "aws" {
  region = "eu-west-1"
}
```
**Purpose**:
- Specifies AWS as the cloud provider
- Sets the geographical region for all resources
- Establishes the foundational cloud configuration

**Why Use**:
- Ensures all resources are created in a consistent region
- Provides authentication and connection context
- Allows easy multi-region deployments by changing this configuration

## 2. `variables.tf`
```hcl
variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "ubuntu_ami" {
  description = "Ubuntu AMI ID"
  type        = string
}
```
**Purpose**:
- Declares input variables for flexible configurations
- Enables dynamic resource creation
- Separates configuration from code

**Why Use**:
- Improves reusability across different environments
- Allows easy updates without modifying core infrastructure code
- Supports environment-specific configurations (dev, staging, prod)

## 3. `s3.tf`
```hcl
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-tf-test-bucket-6565"
}
```
**Purpose**:
- Creates an S3 bucket for object storage
- Provides scalable, durable storage solution

**Why Use**:
- Store application artifacts, backups
- Host static website content
- Implement data lakes or backup strategies
- Secure, scalable cloud storage

## 4. `vpc.tf`
```hcl
# VPC Creation
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.10.0/24"
  map_public_ip_on_launch = true  
  availability_zone = "eu-west-1a"
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.11.0/24"
  availability_zone = "eu-west-1b"
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# VPC Endpoint for DynamoDB
resource "aws_vpc_endpoint" "dynamodb_endpoint" {
  vpc_id       = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.eu-west-1.dynamodb"
  vpc_endpoint_type = "Gateway"
}
```
**Purpose**:
- Creates network infrastructure
- Defines network segmentation
- Enables internet connectivity
- Provides private and public network zones

**Why Use**:
- Isolates resources for security
- Enables controlled internet access
- Supports multi-tier application architectures
- Allows private communication between services
- Implements network-level security

## 5. `security_group.tf`
```hcl
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main_vpc.id

  # HTTP Ingress
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH Ingress (Restricted IP)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["165.1.187.223/32"]
  }

  # All Outbound Traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```
**Purpose**:
- Defines network access rules
- Controls inbound and outbound traffic
- Provides granular security controls

**Why Use**:
- Implements network-level security
- Restricts unauthorized access
- Allows specific, controlled network interactions
- Provides fine-grained traffic management

## 6. `ec2.tf`
```hcl
# SSH Key Pair
resource "aws_key_pair" "my_key" {
  key_name   = var.key_name
  public_key = file("akramul_test_key_pair.pub")
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami                    = var.ubuntu_ami
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.my_key.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
}

# Elastic IP
resource "aws_eip" "web_eip" {
  instance = aws_instance.web_server.id
  domain   = "vpc"
}
```
**Purpose**:
- Provisions compute resources
- Configures server instances
- Enables SSH access
- Provides static IP assignment

**Why Use**:
- Deploy application servers
- Ensure consistent, reproducible server configurations
- Implement secure access mechanisms
- Provide static, predictable IP addresses

## 7. `dynamodb.tf`
```hcl
resource "aws_dynamodb_table" "my_dynamodb_table" {
  name           = "myapp-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
```
**Purpose**:
- Creates a NoSQL database table
- Provides scalable, managed database solution

**Why Use**:
- Store application data
- Implement serverless data storage
- Automatic scaling
- Low-latency data access

## 8. `iam.tf`
```hcl
# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "EC2Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for EC2
resource "aws_iam_policy" "ec2_policy" {
  name        = "EC2Policy"
  description = "Allow EC2 to access S3 & DynamoDB"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "dynamodb:PutItem",
          "dynamodb:GetItem"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM User for Terraform Management
resource "aws_iam_user" "terraform_user" {
  name = "TerraformUser"
}

# Attach Admin Policy to Terraform User
resource "aws_iam_user_policy_attachment" "attach_admin_policy" {
  user       = aws_iam_user.terraform_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
```
**Purpose**:
- Manages access credentials
- Implements least-privilege principle
- Creates service and user accounts

**Why Use**:
- Secure resource access
- Implement fine-grained permissions
- Separate concerns and minimize security risks

## 9. `load_balancer.tf`
```hcl
# Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets           = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
}

# Target Group
resource "aws_lb_target_group" "tg" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
}

# Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
```
**Purpose**:
- Distributes incoming traffic
- Provides high availability
- Enables horizontal scaling

**Why Use**:
- Improve application reliability
- Handle traffic spikes
- Implement advanced routing strategies

## 10. `auto_scaling.tf`
```hcl
# Launch Template
resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-template"
  image_id      = var.ubuntu_ami
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity     = 2
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = [aws_subnet.public_subnet.id]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]
}

# Scaling Policies
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}
```
**Purpose**:
- Automates instance management
- Handles traffic fluctuations
- Ensures application availability

**Why Use**:
- Dynamic resource scaling
- Cost optimization
- High availability
- Automatic capacity management

## Infrastructure Workflow
1. Network Setup (`vpc.tf`)
2. Security Configuration (`security_group.tf`)
3. Compute Provisioning (`ec2.tf`)
4. Database Preparation (`dynamodb.tf`)
5. Access Management (`iam.tf`)
6. Load Distribution (`load_balancer.tf`)
7. Scalability (`auto_scaling.tf`)

**Design Principles**:
- Modularity
- Security-first approach
- Scalability
- Cost-efficiency
- Reproducibility

