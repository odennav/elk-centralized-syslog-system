terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

}


resource "local_file" "ansible_inventory" {
    content = templatefile("../../artifacts/inventory_hosts.tpl",
    {
        cs_ip = values(module.ec2_central)[*].private_ip
        mp_ip = values(module.ec2_workers)[*].private_ip
       


    })
    filename = "../../../inventory"
}

output "central_ips" {
    value = "${formatlist("%v - %v", ec2_central.*.private_ip, ec2_central.*.name)}"
}

output "worker_ips" {
    value = "${formatlist("%v - %v", ec2_workers.*.private_ip, ec2_workers.*.name)}"
}


