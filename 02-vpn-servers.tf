## create the ssh key to use for servers

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


## user data script

data "template_file" "setup" {
  for_each = aws_vpc.sites

  template = file("templates/ec2-setup-instance.sh.tpl")
  
  vars = {
    server_name = each.key
  }
}


## the spot instances

resource "aws_spot_instance_request" "server" {
  for_each = aws_vpc.sites

  ami           = var.instance_ami
  instance_type = var.instance_type
  
  key_name                    = var.studio_name
  vpc_security_group_ids      = [aws_default_security_group.sites[each.key].id, aws_security_group.external[each.key].id]
  subnet_id                   = aws_subnet.sites[each.key].id
  private_ip                  = cidrhost(aws_subnet.sites[each.key].cidr_block, 6)
  associate_public_ip_address = true
  source_dest_check           = true
  disable_api_termination     = false
  user_data                   = data.template_file.setup[each.key].rendered
  
  spot_price = var.spot_price
  spot_type  = "one-time"
  wait_for_fulfillment = true

  tags = {
    Name = "${var.studio_name}_${each.key}"
  }
}

data "aws_instance" "server" {
  for_each = aws_vpc.sites

  instance_id = aws_spot_instance_request.server[each.key].spot_instance_id
}


## tag the spot instances

resource "null_resource" "server" {
  for_each = aws_vpc.sites

  provisioner "local-exec" {
    command = "scripts/ec2-tag-resource.sh"
    
    environment = {
      TAG_PROFILE     = var.aws_profile
      TAG_REGION      = var.aws_region
      TAG_RESOURCE_ID = data.aws_instance.server[each.key].id
      TAG_NAME        = "Name"
      TAG_VALUE       = "${var.studio_name}_${each.key}_vpn"
    }
  }
  
  triggers = {
    spot_requests = aws_spot_instance_request.server[each.key].spot_instance_id
  }
}


## client ssh configuration

resource "local_file" "ssh_config" {
  content = templatefile("templates/ssh.cfg.tpl", {
    config = data.aws_instance.server,
    ssh_username  = "ubuntu",
    ssh_key_file  = local.ssh_private_key_file
    })
    
  filename        = "local/ssh.cfg"
  file_permission = "0640"
}

