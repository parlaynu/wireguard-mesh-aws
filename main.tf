
resource "aws_vpc" "sites" {
  for_each = var.sites
  
  cidr_block           = each.value.cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = each.key
  }
}

