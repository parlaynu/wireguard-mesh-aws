
resource "tls_private_key" "wireguard" {
  provider = invidian-tls
  for_each = aws_vpc.sites

  algorithm   = "ED25519"
}

output "ed25519_public" {
  value = [for k, v in tls_private_key.wireguard : v.public_key_pem]
}

resource "local_file" "wireguard" {
  content = templatefile("templates/wireguard.cfg.tpl", {
    config = tls_private_key.wireguard
    })
    
  filename        = "local/wireguard.cfg"
  file_permission = "0640"
}
