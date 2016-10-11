Role Name
=========

A role to create a tar backup of a file system, encrypt and upload the file to s3

Requirements
------------

AWS access can be provided through a instance profile or using env variables (refer boto configuration settings)
echo "export AWS_ACCESS_KEY_ID=xxxx" >> /etc/profile.d/aws.sh
echo "export AWS_SECRET_ACCESS_KEY=xxxx" >> /etc/profile.d/aws.sh

Role Variables
--------------

local_workspace_param: local workpace base path. default: /tmp/ansible_ws/dr/backups/splunk/
remote_workspace_param: remote workpace base path. default: /opt/local/ansible_ws/dr/backups/splunk/
local_workspace: local workspace path. default: "{{ local_workspace_param }}/{{ timestamp }}"
remote_workspace: remote workspace path. default: "{{ remote_workspace_param }}/{{ timestamp }}"
delete_remote_ws: flag to delete remote workspace before starting the backup process. default: "False"
appb_dumps_dir: dir to store the backup file @ remote ws. default: "{{ remote_workspace }}/dumps"
appb_is_cold_backup: flag to indicate cold or hot backup. default: "False"
appb_app_name: application/stack name. default: "splunk"
appb_app_component_name: component name. default: "NA"
appb_app_home: application home or backup home. default: "/opt/splunk/etc"
appb_service_stop: application stop command. default: "hostname"
appb_service_start: application start command. default: "hostname"
appb_dump_name: dump file name. default: "{{ appb_app_name }}_{{ timestamp }}.tgz"
appb_bkp_set_dump_name: backup set dump file name. default: "{{ appb_dump_name }}"
appb_bkp_set_enc_file_name: backup set encrypted dump file name. default: "{{ appb_app_name }}_{{ timestamp }}.enc"
appb_bkp_set_cmd: backup set dump command. default: "cd {{ appb_app_home }} && touch {{ appb_dumps_dir }}/{{ appb_dump_name }} && tar -czf {{ appb_dumps_dir }}/{{ appb_dump_name }} *"
appb_bkp_set_encrypt_cmd:command to encrypt the raw dump file. default: "openssl enc -aes-256-cbc -k {{ appb_compress_encrypt_key }} -salt -in {{ appb_bkp_set_dump_name }} -out {{ appb_dumps_dir }}/{{ appb_bkp_set_enc_file_name }}"
appb_compress_encrypt_key: encrypt key. default:  "xRz96aRS5F2XBrz6sJTq"
appb_bkp_set_src: raw dump file src. default: "{{ appb_dumps_dir }}/{{ appb_bkp_set_enc_file_name }}"
appb_publish_to_s3: flag to upload the backup file to s3 . default: "False"
appb_bkp_s3_bucket: s3 bucket name. default: dr-backups
appb_bkp_s3_backup_dir: s3 backup dir. default: "{{ appb_app_name }}"
appb_bkp_s3_object_current: s3 object path. default: "{{ appb_bkp_s3_backup_dir }}/{{ hostname }}-{{ timestamp }}.enc"

Dependencies
------------

NA

Example Playbook
----------------

        ---
        - hosts: all
          gather_facts: yes

          roles:
            - dr/backups/app

License
-------
BSD

Author Information
------------------
Durai Govindasamy | duraivkg@gmail.com | https://www.linkedin.com/pub/durai-govindasamy/68/81a/239
