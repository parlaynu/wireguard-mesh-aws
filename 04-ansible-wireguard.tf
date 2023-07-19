locals {
  wireguard_role = "wireguard"
}

resource "template_dir" "wireguard" {
  source_dir = "templates/ansible-roles/${local.wireguard_role}"
  destination_dir = "local/ansible/roles/${local.wireguard_role}"
  
  vars = {}
}

