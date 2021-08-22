## my public ip address - used in security groups

data "external" "my_public_ip" {
  program = ["scripts/my-public-ip.sh"]
}


## create the VPC

resource "aws_vpc" "sites" {
  for_each = var.sites
  
  cidr_block           = each.value.cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "${var.studio_name}_${each.key}"
  }
}


## tag default VPC resources

resource "aws_default_route_table" "sites" {
  for_each = aws_vpc.sites
  
  default_route_table_id = each.value.default_route_table_id
  tags = {
    Name = "${var.studio_name}_${each.key}"
  }
}

resource "aws_default_security_group" "sites" {
  for_each = aws_vpc.sites

  vpc_id = each.value.id
  tags = {
    Name = "${var.studio_name}_${each.key}"
  }

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["${data.external.my_public_ip.result["my_public_ip"]}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## create the internet gateway

resource "aws_internet_gateway" "sites" {
  for_each = aws_vpc.sites

  vpc_id = each.value.id
  tags = {
    Name = "${var.studio_name}_${each.key}"
  }
}

## create the subnet

resource "aws_subnet" "sites" {
  for_each = aws_vpc.sites

  vpc_id     = each.value.id
  cidr_block = each.value.cidr_block

  tags = {
    Name = "${var.studio_name}_${each.key}"
  }
}

resource "aws_route_table_association" "sites_public" {
  for_each = aws_vpc.sites

  route_table_id = each.value.main_route_table_id
  subnet_id      = aws_subnet.sites[each.key].id
}

resource "aws_route" "sites_public_default" {
  for_each = aws_vpc.sites

  route_table_id         = each.value.main_route_table_id
  gateway_id             = aws_internet_gateway.sites[each.key].id
  destination_cidr_block = "0.0.0.0/0"
}

