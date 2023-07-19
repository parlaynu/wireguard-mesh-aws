## ssh access to the instances

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = local.ssh_private_key_file
  file_permission = "0600"
}

resource "aws_key_pair" "ssh_key" {
  key_name   = var.studio_name
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "ssh_config" {
  content = templatefile("templates/ssh.cfg.tpl", {
    vpn_config = data.aws_instance.vpn_server,
    prv_config = data.aws_instance.private_server,
    ssh_username  = "ubuntu",
    ssh_key_file  = local.ssh_private_key_file
    })
    
  filename        = "local/ssh.cfg"
  file_permission = "0640"
}


## the spot instances

resource "aws_spot_instance_request" "vpn_server" {
  for_each = aws_vpc.sites

  ami           = var.instance_ami
  instance_type = var.instance_type
  
  key_name                    = aws_key_pair.ssh_key.key_name
  vpc_security_group_ids      = [aws_default_security_group.sites[each.key].id, aws_security_group.external[each.key].id]
  subnet_id                   = aws_subnet.sites_public[each.key].id
  private_ip                  = cidrhost(aws_subnet.sites_public[each.key].cidr_block, 6)
  associate_public_ip_address = true
  source_dest_check           = false
  disable_api_termination     = false
  user_data                   = templatefile("templates/ec2-setup-vpn-instance.sh.tpl", {
      server_name = "${each.key}-vpn"
    })
  
  spot_price = var.spot_price
  spot_type  = "one-time"
  wait_for_fulfillment = true

  tags = {
    Name = "${var.studio_name}_${each.key}_vpn"
  }
  
  # the gateway route needs to be in place so the 
  # instance setup scripts can run
  depends_on = [
    aws_route.sites_public_default
  ]
}

data "aws_instance" "vpn_server" {
  for_each = aws_vpc.sites

  instance_id = aws_spot_instance_request.vpn_server[each.key].spot_instance_id
}

# an artificial dependency on the instances to wait for them to be
# in the running state. required by some resources such as routes
# with the instance_id as the target.
resource "null_resource" "instance_ready" {
  for_each = data.aws_instance.vpn_server
  
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      host = each.value.public_ip
      user = "ubuntu"
      private_key = file(local.ssh_private_key_file)
    }

    inline = [
      "ping -c 2 localhost"
    ]
  }
  
  depends_on = [
    local_file.ssh_private_key
  ]
}

## tag the spot instances

resource "null_resource" "vpn_server" {
  for_each = data.aws_instance.vpn_server

  provisioner "local-exec" {
    command = "scripts/ec2-tag-resource.sh"
    
    environment = {
      TAG_PROFILE     = var.aws_profile
      TAG_REGION      = var.aws_region
      TAG_RESOURCE_ID = each.value.id
      TAG_NAME        = "Name"
      TAG_VALUE       = "${var.studio_name}_${each.key}_vpn"
    }
  }
  
  triggers = {
    spot_requests = aws_spot_instance_request.vpn_server[each.key].spot_instance_id
  }
}

## disable source-dest-check (doesn't work from the spot request)

resource "null_resource" "vpn_server_src_dst_check" {
  for_each = data.aws_instance.vpn_server

  provisioner "local-exec" {
    command = "scripts/ec2-disable-src-dst-check.sh"
    
    environment = {
      AWS_PROFILE = var.aws_profile
      AWS_REGION  = var.aws_region
      INSTANCE_ID = each.value.id
    }
  }
  
  triggers = {
    spot_requests = aws_spot_instance_request.vpn_server[each.key].spot_instance_id
  }
}





