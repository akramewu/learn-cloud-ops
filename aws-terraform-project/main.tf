provider "aws" {
  region = "eu-west-1"

}
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-tf-test-bucket-6565"
}

# create vpc 
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    name = "MainVPC"
  }
  }

# create subnet for public and private
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.10.0/24"
  map_public_ip_on_launch = true  
  availability_zone = "eu-west-1a"
    tags = {
        name = "public_subnet"
    }
}

resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = "10.0.11.0/24"
  availability_zone = "eu-west-1b"
        tags = {
            name = "private_subnet"
        }
  
}

# creae internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    name = "InternetGateway"
  }
}

# create route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
    }
  tags = {
    name = "PublicRouteTable"
  }  
}
  # associate route table with subnet
    resource "aws_route_table_association" "public_route_table_association" {
        subnet_id = aws_subnet.public_subnet.id
        route_table_id = aws_route_table.public_route_table.id
    }

# create security group
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main_vpc.id

  # Allow inbound HTTP (port 80) access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound SSH access (ONLY FROM YOUR IP)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["165.1.187.223/32"]  # Replace with your IP
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebSecurityGroup"
  }
}

# add public key to terraform
resource "aws_key_pair" "my_key" {
  key_name   = var.key_name
  public_key = file("akramul_test_key_pair.pub")
}

# create ec2 instance
resource "aws_instance" "web_server" {
  ami           = var.ubuntu_ami
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_key.key_name
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "WebServer"
  }
}

# add elastic ip
resource "aws_eip" "web_eip" {
  instance = aws_instance.web_server.id
  domain      = "vpc"

  tags = {
    Name = "WebEIP"
  }
}

# Create a DynamoDB Table
resource "aws_dynamodb_table" "my_dynamodb_table" {
  name           = "myapp-table"
  billing_mode   = "PAY_PER_REQUEST"  # No capacity planning needed (scales automatically)
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"  # String type (Primary Key)
  }

  tags = {
    Name = "MyDynamoDBTable"
  }
}

# allow ec2 instance to access dynamodb -> ec2 instance need permission to access dynamodb
# create an IAM role for EC2 instance
resource "aws_iam_role" "ec2_dynamodb_role" {
  name = "EC2DynamoDBAccessRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
# attach policy to allow dynamoDB access
resource "aws_iam_policy" "dynamodb_access_policy" {
  name        = "DynamoDBAccessPolicy"
  description = "Allow EC2 to access DynamoDB"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:Scan",
        "dynamodb:Query",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "${aws_dynamodb_table.my_dynamodb_table.arn}"
    }
  ]
}
EOF
}

# attach policy to role
resource "aws_iam_role_policy_attachment" "attach_dynamodb_policy" {
  role       = aws_iam_role.ec2_dynamodb_role.name
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}

# attach role to ec2 instance
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_dynamodb_role.name
}
