---
- hosts: all
  become: yes
  gather_facts: yes
  
  vars:
    ansible_python_interpreter: "/usr/bin/env python3"

  tasks:
  - import_role:
      name: ${wireguard_role}

