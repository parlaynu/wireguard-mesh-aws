---
server_name: ${server_name}
public_ip: ${public_ip}
private_ip: ${private_ip}
cidr_block: ${cidr_block}

vpn_cidr_block: ${vpn_cidr_block}
vpn_ip: ${vpn_ip}
vpn_netlen: ${vpn_netlen}
vpn_private_key: ${vpn_private_key}
vpn_listen_port: 51820

peers:
%{ for peer in peers ~}
- name: ${peer.name}
  public_ip: ${peer.public_ip}
  cidr_block: ${peer.cidr_block}
  vpn_ip: ${peer.vpn_ip}
  vpn_public_key: ${peer.vpn_public_key}
%{ endfor ~}
