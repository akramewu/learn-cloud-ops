provider "aws" {
  region = var.region
}

module "network" {
  source              = "./modules/network"
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  availability_zone   = var.availability_zone
  allowed_ssh_ip      = var.allowed_ssh_ip
}
/*
module "storage" {
  source       = "./modules/storage"
  bucket_name  = var.bucket_name
  dynamodb_name = var.dynamodb_name
}
*/
module "iam" {
  source = "./modules/iam"
}

module "ec2" {
  source          = "./modules/ec2"
  ami_id          = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  subnet_id       = module.network.public_subnet_id
  security_group_id = module.network.security_group_id
  iam_profile     = module.iam.ec2_instance_profile
  private_key_path       = var.private_key_path
}
