[Interface]
PrivateKey = ${private_key}
ListenPort = 51820

%{ for peer in peers }
[Peer]
PublicKey  = ${peer.public_key}
Endoint    = ${peer.public_ip}:51820
AllowedIPs = ${peer.private_ip}/32
%{ endfor ~}
