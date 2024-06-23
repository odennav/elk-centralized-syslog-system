# Terraform Block

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

}

module "vpc" {
  source = "./modules/vpc"
}

output "vpc" {
  description = "id of virtual private cloud"
  value = module.vpc.vpc_id
}

module "security_group" {
  source = "./modules/security_group"
}

output "public_security_group" {
  description = "id of bastion security group"
  value = module.security_group.public_bastion_sg_group_id
}

output "private_security_group" {
  description = "id of private security group"
  value = module.security_group.private_sg_group_id
}

module "ec2_public" {
  source = "./modules/ec2_public"
}

output "ec2_public_id" {
  description = "id of ec2_bastion machine"
  value = module.ec2_public.ec2_bastion_public_instance_ids
}

output "ec2_public_ip" {
  description = "ec2_bastion machine ipv4 address"
  value = module.ec2_public.ec2_bastion_public_ip
}

module "ec2_cellusys" {
  source = "./modules/ec2_cellusys"
}

output "ec2_central_instance_id" {
  description = "id of the central servers"
  value = module.ec2_central.ec2_central_instance_id
}

output "ec2_central_server_ip" {
  description = "ipv4 address of the central servers"
  value = module.ec2_central.ec2_central_ip
}

output "ec2_message_workers_id" {
  description = "id of the message processors"
  value = module.ec2_workers.ec2_workers_instance_id
}

output "ec2_message_workers_ip" {
  description = "ipv4 addresses of the message processors"
  value = module.ec2_workers.ec2_workers_ip
}


