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
    Name = "${var.studio_name}_${each.key}_internal"
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

## create the public subnets and routes

resource "aws_subnet" "sites_public" {
  for_each = aws_vpc.sites

  vpc_id     = each.value.id
  cidr_block = cidrsubnet(each.value.cidr_block, 2, 0)
  availability_zone = var.aws_zone

  tags = {
    Name = "${var.studio_name}_${each.key}_pub"
  }
}

resource "aws_route_table_association" "sites_public" {
  for_each = aws_vpc.sites

  route_table_id = each.value.main_route_table_id
  subnet_id      = aws_subnet.sites_public[each.key].id
}

resource "aws_route" "sites_public_default" {
  for_each = aws_vpc.sites

  route_table_id         = each.value.main_route_table_id
  gateway_id             = aws_internet_gateway.sites[each.key].id
  destination_cidr_block = "0.0.0.0/0"
}


## create the private subnets and routes

resource "aws_subnet" "sites_private" {
  for_each = aws_vpc.sites

  vpc_id     = each.value.id
  cidr_block = cidrsubnet(each.value.cidr_block, 2, 1)
  availability_zone = var.aws_zone

  tags = {
    Name = "${var.studio_name}_${each.key}_prv"
  }
}

resource "aws_route_table" "sites_private" {
  for_each = aws_vpc.sites

  vpc_id = each.value.id
  tags = {
    Name = "${var.studio_name}_${each.key}_prv"
  }  
}

resource "aws_route_table_association" "sites_private" {
  for_each = aws_vpc.sites

  route_table_id = aws_route_table.sites_private[each.key].id
  subnet_id      = aws_subnet.sites_private[each.key].id
}

resource "aws_route" "sites_private_default" {
  for_each = aws_vpc.sites

  route_table_id = aws_route_table.sites_private[each.key].id
  instance_id    = data.aws_instance.vpn_server[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  
  depends_on = [
    null_resource.instance_ready
  ]
}

resource "aws_route" "sites_private_internal" {
  for_each = local.site_peers

  route_table_id = aws_route_table.sites_private[each.value.local_name].id
  instance_id    = data.aws_instance.vpn_server[each.value.local_name].id
  destination_cidr_block = each.value.remote_net

  depends_on = [
    null_resource.instance_ready
  ]
}

resource "aws_route" "sites_private_vpn" {
  for_each = aws_vpc.sites

  route_table_id = aws_route_table.sites_private[each.key].id
  instance_id    = data.aws_instance.vpn_server[each.key].id
  destination_cidr_block = var.vpn_cidr_block

  depends_on = [
    null_resource.instance_ready
  ]
}
