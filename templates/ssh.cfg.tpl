%{ for key, value in prv_config }
Host ${key}_prv
  Hostname ${value.private_ip}
  ProxyJump ${key}_vpn
%{ endfor ~}

%{ for key, value in vpn_config }
Host ${key}_vpn
  Hostname ${value.public_ip}
%{ endfor ~}

Host *
  User ${ssh_username}
  IdentityFile ${ssh_key_file}
  IdentitiesOnly yes
