---
server_name: ${server_name}
public_ip: ${public_ip}

private_key: ${private_key}
listen_port: 51820

peers:
%{ for peer in peers ~}
- name: ${peer.name}
  public_key: ${peer.public_key}
  public_ip: ${peer.public_ip}
  private_ip: ${peer.private_ip}
%{ endfor ~}
