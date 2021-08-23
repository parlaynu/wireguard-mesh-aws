
resource "local_file" "wireguard" {
  for_each = data.aws_instance.vpn_server
  
  content = templatefile("templates/wireguard.cfg.tpl", {
    servername       = each.key,
    public_ip        = each.value.public_ip,
    private_ip       = each.value.private_ip,
    private_key      = var.sites[each.key].private_key,
    peers = [for k, v in data.aws_instance.vpn_server :
        {
          name = k,
          public_key = var.sites[k].public_key,
          cidr_block = var.sites[k].cidr_block,
          public_ip = v.public_ip,
          private_ip = v.private_ip,
        }
        if k != each.key
      ]
    })
    
  filename        = "local/wireguard-${each.key}.cfg"
  file_permission = "0640"
}
