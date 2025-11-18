############################################
# Load Networking Module
############################################
module "networking" {
  source = "./networking"

  project             = var.project
  vpc_cidr            = var.vpc_cidr
  public_subnet_a     = var.public_subnet_a
  public_subnet_b     = var.public_subnet_b
  private_subnet_a    = var.private_subnet_a
  private_subnet_b    = var.private_subnet_b
  availability_zone_a = var.availability_zone_a
  availability_zone_b = var.availability_zone_b
}

############################################
# Load Balancer Module (DISABLED)
# Your AWS account does NOT support ALB.
# Enable ALB later by UNCOMMENTING this block.
############################################
# module "loadbalancer" {
#   source         = "./loadbalancer"
#   project        = var.project
#   vpc_id         = module.networking.vpc_id
#   public_subnets = module.networking.public_subnets
# }

############################################
# Compute Module (NO ALB MODE)
############################################
module "compute" {
  source          = "./compute"

  project         = var.project
  vpc_id          = module.networking.vpc_id
  private_subnets = module.networking.private_subnets

  # ALB disabled (do not send these)
  # alb_sg_id        = module.loadbalancer.alb_sg_id
  # target_group_arn = module.loadbalancer.target_group_arn

  ami_id          = var.ami_id
  instance_type   = var.instance_type
  asg_min         = var.asg_min
  asg_max         = var.asg_max
  asg_desired     = var.asg_desired
}
