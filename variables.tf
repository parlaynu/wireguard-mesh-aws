
variable "studio_name" {
  default = "s1330"
}

variable "sites" {
  type = map(object({
    hostnum = number,
    cidr_block = string,
    private_key = string,
    public_key = string
  }))
  default = {
    core = {
      hostnum = 100
      cidr_block  = "192.168.100.0/24"
      private_key = ""
      public_key  = ""
    }
    site1 = {
      hostnum = 101
      cidr_block  = "192.168.101.0/24"
      private_key = ""
      public_key  = ""
    }
    site2 = {
      hostnum = 102
      cidr_block  = "192.168.102.0/24"
      private_key = ""
      public_key  = ""
    }
    site3 = {
      hostnum = 103
      cidr_block  = "192.168.103.0/24"
      private_key = ""
      public_key  = ""
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
  default = ""
}

variable "aws_zone" {
  default = ""
}

variable "instance_type" {
  default = "t2.micro"
}

variable "instance_ami" {
  default = ""
}

variable "spot_price" {
  default = 0.02
}

locals {
  ssh_private_key_file = "local/pki/${var.studio_name}"
}

