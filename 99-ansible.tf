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
      wireguard_role = local.wireguard_role
    })
  filename = "local/ansible/playbook.yml"
}


## render host variables

resource "local_file" "hostvars" {
  for_each = data.aws_instance.vpn_server
  
  content = templatefile("templates/ansible/hostvars.yml.tpl", {
    server_name      = each.key,
    cidr_block       = aws_vpc.sites[each.key].cidr_block
    public_ip        = each.value.public_ip,

    vpn_cidr_block   = var.vpn_cidr_block
    vpn_ip           = cidrhost(var.vpn_cidr_block, var.sites[each.key].hostnum)
    vpn_netlen       = split("/", var.vpn_cidr_block)[1]
    
    private_key      = var.sites[each.key].private_key,
    
    peers = [for k, v in data.aws_instance.vpn_server :
        {
          name = k
          public_key = var.sites[k].public_key
          cidr_block = var.sites[k].cidr_block
          public_ip = v.public_ip
          private_ip = v.private_ip
          vpn_ip = cidrhost(var.vpn_cidr_block, var.sites[k].hostnum)
        }
        if k != each.key
      ]
    })
    
  filename        = "local/ansible/host_vars/${each.key}.yml"
  file_permission = "0640"
}


## render the inventory file

resource "local_file" "inventory" {
  content = templatefile("templates/ansible/inventory.ini.tpl", {
    gateways = join("\n", keys(var.sites))
    })
  filename = "local/ansible/inventory.ini"
}


