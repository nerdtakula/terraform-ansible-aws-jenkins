---
[jenkins_master]
${public_ip} ansible_user=${ansible_user} ansible_ssh_private_key_file=${private_ssh_key}

[jenkins_master:vars]
%{ for k, v in ansible_vars ~}
${k} = ${v}
%{ endfor ~}
