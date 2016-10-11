Role Name
=========

Role to encryp file or list of files using ansible-vault (python cryptography)
there are two types of vault encryption, either we can provide staic list of files or command to find list of files dynamically

Requirements
------------

ansible-vault

Role Variables
--------------

local_workspace_param: local workpace base path. . default: /opt/local/ansible/ansible_ws/vault
local_workspace:  local workspace path.. default:"{{ local_workspace_param }}/{{ timestamp }}"
vault_dynamic_home: . default:"${ANSIBLE_ROLES}"
vault_mode: . default: encrypt
vault_encrypt_mode: vault file lookup mode static/dynamic. default: dynamic
vault_dynamic_lf: lookup file name for dynamic mode. default: "{{ local_workspace }}/.lf_file_list.md"
vault_cmd: valul command string for dynamic mode. default: "find {{ vault_dynamic_home }} -name main.yml | grep \"vars/\" > {{ vault_dynamic_lf }} && for file in `cat {{ vault_dynamic_lf }}`; do ansible-vault {{ vault_mode }} ${file}; done"
vault_static_files: list of files for static mode
  - "${ANSIBLE_ROLES}/backups/chef_server/vars/main.yml"
  - "${ANSIBLE_ROLES}/backups/app/vars/main.yml"

Dependencies
------------

NA

Example Playbook
----------------

    ---
    - hosts: localhost
      remote_user: root
      roles:
        - security/vault

License
-------

BSD

Author Information
------------------

Durai Govindasamy | duraivkg@gmail.com | https://www.linkedin.com/pub/durai-govindasamy/68/81a/239
