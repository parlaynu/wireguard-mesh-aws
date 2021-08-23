## render the run script

data "template_file" "run_playbook" {
  template = file("templates/ansible/run-ansible.sh.tpl")

  vars = {
    inventory_file = "inventory.ini"
  }
}

resource "local_file" "run_playbook" {
  content = data.template_file.run_playbook.rendered
  filename = "local/ansible/run-ansible.sh"
  file_permission = "0755"
}


## render the playbook

data "template_file" "playbook" {
  template = file("templates/ansible/playbook.yml.tpl")
  vars = {
    wireguard_role = local.wireguard_role
  }
}

resource "local_file" "playbook" {
  content = data.template_file.playbook.rendered
  filename = "local/ansible/playbook.yml"
}


## render host variables

data "template_file" "hostvars" {
  for_each = data.aws_instance.vpn_server
  
  template = file("templates/ansible/hostvars.yml.tpl")

  vars = {
    server_name = each.key
    server_address = each.value.public_ip
  }
}

resource "local_file" "hostvars" {
  for_each = data.template_file.hostvars
  
  content = each.value.rendered
  filename = "local/ansible/host_vars/${each.value.vars["server_name"]}.yml"
}


## render the inventory file

data "template_file" "inventory" {
  template = file("templates/ansible/inventory.ini.tpl")

  vars = {
    gateways = join("\n", keys(var.sites))
  }
}

resource "local_file" "inventory" {
  content = data.template_file.inventory.rendered
  filename = "local/ansible/inventory.ini"
}


