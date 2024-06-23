# AWS EC2 Instance Terraform Variables
# EC2 Instance Variables

# AWS EC2 Instance Type
variable "instance_type" {
  description = "EC2 Instance Type"
  type = string
  default = "t3.micro"  
}

# AWS EC2 Instance Key Pair
variable "instance_keypair" {
  description = "AWS EC2 Key pair that need to be associated with EC2 Instance"
  type = string
  default = "terraform-key"
}

variable "central" {
  description = "Variable used as name of central node"
  type = string
  default = "central-server"
}

variable "worker" {
  description = "Variable used as name of worker node"
  type = string
  default = "message-processor"
}


