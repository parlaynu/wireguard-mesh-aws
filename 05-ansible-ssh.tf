locals {
  ssh_role = "ssh"
}

resource "template_dir" "ssh" {
  source_dir = "templates/ansible-roles/${local.ssh_role}"
  destination_dir = "local/ansible/roles/${local.ssh_role}"
  
  vars = {
    studio_name = var.studio_name
    vpn_servers = join("\n", [for k, v in data.aws_instance.vpn_server : 
      format("- name: %s-vpn\n  private_ip: %s", k, v.private_ip)
    ])
    prv_servers = join("\n", [for k, v in data.aws_instance.private_server : 
      format("- name: %s-prv\n  private_ip: %s", k, v.private_ip)
    ])
    ssh_private_key = tls_private_key.ssh_key.private_key_pem
  }
}

