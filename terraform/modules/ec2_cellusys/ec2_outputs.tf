# AWS EC2 Instance Terraform Outputs

# Private EC2 Central Instances
## ec2_central_instance_id
output "ec2_central_instance_ids" {
  description = "List of IDs of instances"
  value = [for ec2central in module.ec2_central: ec2central.id ]   
}

## ec2_central_ip
output "ec2_central_ip" {
  description = "List of private IP addresses assigned to the Central server instances"
  value = [for ec2central in module.ec2_central: ec2central.private_ip ]  
}


# Private EC2 Workers Instances
## ec2_workers_instance_id
output "ec2_workers_instance_ids" {
  description = "List of IDs of the message processor instances"
  value = [for ec2worker in module.ec2_workers: ec2workers.id ]
}

## ec2_workers_ip
output "ec2_workers_ip" {
  description = "List of private IP addresses assigned to the message processor instances"
  value = [for ec2worker in module.ec2_workers: ec2workers.private_ip ]
}

