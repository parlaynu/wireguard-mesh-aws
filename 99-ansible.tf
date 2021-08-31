## render the run script

resource "local_file" "run_playbook" {
  content = templatefile("templates/ansible/run-ansible.sh.tpl", {
      inventory_file = "inventory.ini"
    })
  filename = "local/ansible/run-ansible.sh"
  file_permission = "0755"
}


## render the playbook

resource "local_file" "playbook" {
  content = templatefile("templates/ansible/playbook.yml.tpl", {
      wireguard_role = local.wireguard_role,
      ssh_role = local.ssh_role
    })
  filename = "local/ansible/playbook.yml"
}


## render host variables

resource "local_file" "hostvars_vpn" {
  for_each = data.aws_instance.vpn_server
  
  content = templatefile("templates/ansible/hostvars-vpn.yml.tpl", {
    server_name      = "${each.key}-vpn",
    public_ip        = each.value.public_ip,
    private_ip       = each.value.private_ip
    cidr_block       = aws_vpc.sites[each.key].cidr_block

    vpn_cidr_block   = var.vpn_cidr_block
    vpn_netlen       = split("/", var.vpn_cidr_block)[1]
    vpn_ip           = cidrhost(var.vpn_cidr_block, var.sites[each.key].vpn_hostnum)
    vpn_private_key  = var.sites[each.key].vpn_private_key,
    
    peers = [for k, v in data.aws_instance.vpn_server :
        {
          name = k
          cidr_block = var.sites[k].cidr_block
          public_ip = v.public_ip
          private_ip = v.private_ip
          vpn_public_key = var.sites[k].vpn_public_key
          vpn_ip = cidrhost(var.vpn_cidr_block, var.sites[k].vpn_hostnum)
        }
        if k != each.key
      ]
    })
    
  filename        = "local/ansible/host_vars/${each.key}-vpn.yml"
  file_permission = "0640"
}

resource "local_file" "hostvars_prv" {
  for_each = data.aws_instance.private_server
  
  content = templatefile("templates/ansible/hostvars-prv.yml.tpl", {
    server_name = "${each.key}-prv",
    private_ip   = each.value.private_ip,
  })
  
  filename        = "local/ansible/host_vars/${each.key}-prv.yml"
  file_permission = "0640"
}

## render the inventory file

resource "local_file" "inventory" {
  content = templatefile("templates/ansible/inventory.ini.tpl", {
    gateways = join("\n", [for k, v in data.aws_instance.vpn_server : format("%s-vpn", k)]),
    servers  = join("\n", [for k, v in data.aws_instance.private_server : format("%s-prv", k)])
    })
  filename = "local/ansible/inventory.ini"
}
