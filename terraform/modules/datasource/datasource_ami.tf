terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

}

#Get latest AMI ID for Centos 8

data "aws_ami" "centos_8" {
  most_recent = true
  owners      = ["125523088429"] # CentOS's AWS Account ID

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["CentOS 8 x86_64 *"]
  }
}







