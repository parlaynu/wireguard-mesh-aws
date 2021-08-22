%{ for key, value in config }
Host ${key}
  Hostname ${value.public_ip}
  User ${ssh_username}
  IdentityFile ${ssh_key_file}
  IdentitiesOnly yes
%{ endfor ~}
