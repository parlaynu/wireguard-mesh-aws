---
server_name: ${server_name}
public_ip: ${public_ip}
vpn_ip: ${vpn_ip}

private_key: ${private_key}
listen_port: 51820

peers:
%{ for peer in peers ~}
- name: ${peer.name}
  public_ip: ${peer.public_ip}
  vpn_ip: ${peer.vpn_ip}
  public_key: ${peer.public_key}
%{ endfor ~}
