
variable "sites" {
  type = map(object({
    cidr_block = string
  }))
  default = {
    core = {
      cidr_block = "192.168.100.0/24"
    }
    site1 = {
      cidr_block = "192.168.101.0/24"
    }
    site2 = {
      cidr_block = "192.168.102.0/24"
    }
    site3 = {
      cidr_block = "192.168.103.0/24"
    }
  }
}

variable "aws_profile" {
  default = ""
}

variable "aws_region" {
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

variable "studio_name" {
  default = "s1330"
}

locals {
  ssh_private_key_file = "local/pki/${var.studio_name}"
}

