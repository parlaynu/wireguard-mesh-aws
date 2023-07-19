
## the spot instances

resource "aws_spot_instance_request" "private_server" {
  for_each = aws_vpc.sites

  ami           = var.instance_ami
  instance_type = var.instance_type
  
  key_name                    = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids      = [aws_default_security_group.sites[each.key].id, aws_security_group.external[each.key].id]
  subnet_id                   = aws_subnet.sites_private[each.key].id
  private_ip                  = cidrhost(aws_subnet.sites_private[each.key].cidr_block, 6)
  associate_public_ip_address = false
  source_dest_check           = true
  disable_api_termination     = false
  user_data                   = templatefile("templates/ec2-setup-prv-instance.sh.tpl", {
      server_name = "${each.key}-prv"
    })
  
  spot_price = var.spot_price
  spot_type  = "one-time"
  wait_for_fulfillment = true

  tags = {
    Name = "${var.studio_name}_${each.key}_prv"
  }
  
  # the gateway route needs to be in place so the 
  # instance setup scripts can run
  depends_on = [
    aws_route.sites_private_default
  ]
}

data "aws_instance" "private_server" {
  for_each = aws_vpc.sites

  instance_id = aws_spot_instance_request.private_server[each.key].spot_instance_id
}

## tag the spot instances

resource "null_resource" "private_server" {
  for_each = aws_vpc.sites

  provisioner "local-exec" {
    command = "scripts/ec2-tag-resource.sh"
    
    environment = {
      TAG_PROFILE     = var.aws_profile
      TAG_REGION      = var.aws_region
      TAG_RESOURCE_ID = data.aws_instance.private_server[each.key].id
      TAG_NAME        = "Name"
      TAG_VALUE       = "${var.studio_name}_${each.key}_prv"
    }
  }
  
  triggers = {
    spot_requests = aws_spot_instance_request.private_server[each.key].spot_instance_id
  }
}


