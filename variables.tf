
variable "studio_name" {
  default = "s1330"
}

variable "sites" {
  type = map(object({
    cidr_block = string,
    vpn_hostnum = number,
    vpn_private_key = string,
    vpn_public_key = string
  }))
  default = {
    site0 = {
      cidr_block = "192.168.100.0/24"
      vpn_hostnum     = 100
      vpn_private_key = ""
      vpn_public_key  = ""
    }
    site1 = {
      cidr_block = "192.168.101.0/24"
      vpn_hostnum     = 101
      vpn_private_key = ""
      vpn_public_key  = ""
    }
    site2 = {
      cidr_block = "192.168.102.0/24"
      vpn_hostnum     = 102
      vpn_private_key = ""
      vpn_public_key  = ""
    }
    site3 = {
      cidr_block = "192.168.103.0/24"
      vpn_hostnum     = 103
      vpn_private_key = ""
      vpn_public_key  = ""
    }
  }
}

locals {
  sites = [
    for site, values in var.sites : {
      name = site
      cidr_block = values.cidr_block
    }
  ]
  
  site_peers = {
    for pair in setproduct(local.sites, local.sites) : "${pair[0].name}_${pair[1].name}" => {
      local_name  = pair[0].name
      local_net   = pair[0].cidr_block
      remote_name = pair[1].name
      remote_net  = pair[1].cidr_block
    }
    if pair[0].name != pair[1].name
  }
}

variable "vpn_cidr_block" {
  default = "192.168.99.0/24"
}

variable "aws_profile" {
  default = ""
}

variable "aws_region" {
  default = "ap-southeast-2"
}

variable "aws_zone" {
  default = "ap-southeast-2c"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "instance_ami" {
  default = "ami-0567f647e75c7bc05"
}

variable "spot_price" {
  default = 0.02
}

locals {
  ssh_private_key_file = "local/pki/${var.studio_name}"
}

