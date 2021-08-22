## aws definitions

variable "aws_profile" {
  default = ""
}

variable "aws_region" {
  default = ""
}

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
