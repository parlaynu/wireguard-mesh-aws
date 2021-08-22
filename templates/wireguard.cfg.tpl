%{ for key, value in config }
Host ${key}
${value.private_key_pem}
%{ endfor ~}
