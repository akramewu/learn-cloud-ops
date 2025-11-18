############################################
# Root Module Outputs (Expose Key Info)
############################################

output "vpc_id" {
  description = "VPC ID from networking module"
  value       = module.networking.vpc_id
}

output "public_subnets" {
  description = "Public subnets created by networking module"
  value       = module.networking.public_subnets
}

output "private_subnets" {
  description = "Private subnets created by networking module"
  value       = module.networking.private_subnets
}

# output "alb_dns" {
#   description = "DNS name of the Application Load Balancer (disabled)"
#   value       = module.loadbalancer.alb_dns_name
# }



output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.compute.asg_name
}
