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
    Name = "${var.studio_name}_${each.key}_default"
  }

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "external" {
  for_each = aws_vpc.sites
  
  name        = "external"
  description = "Allow external inbound traffic"
  vpc_id      = each.value.id
  tags = {
    Name = "${var.studio_name}_${each.key}_external"
  }
}

resource "aws_security_group_rule" "egress" {
  for_each = aws_security_group.external
  
  security_group_id = each.value.id
  type              = "egress"
  protocol          = -1
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "external_ssh" {
  for_each = aws_security_group.external
  
  security_group_id = each.value.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["${data.external.my_public_ip.result["my_public_ip"]}/32"]
}

resource "aws_security_group_rule" "external_wireguard" {
  for_each = aws_security_group.external
  
  security_group_id = each.value.id
  type              = "ingress"
  protocol          = "udp"
  from_port         = 51820
  to_port           = 51820
  cidr_blocks       = [for k, v in data.aws_instance.vpn_server : "${v.public_ip}/32" if k != each.key]
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

