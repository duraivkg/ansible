Role Name
=========

Role to execute any script at remote/local machine and upload file(s) to s3. This will be very helpful when we tie this role through Jenkins job, workflow , it can accomadate any kind of ad-hoc script exections.

Requirements
------------

NA

Role Variables
--------------

python_interpreter:  python interpreter. default: "/usr/bin/env python"
local_workspace_param:  local workpace base path. default: /tmp/ws/utilities/shell/
remote_workspace_param: remote workpace base path. default: /opt/local/jenkins/.ws/utilities/shell/
local_workspace:  local workspace path. default: "{{ local_workspace_param }}/{{ timestamp }}"
remote_workspace:  remote workspace path. default: "{{ remote_workspace_param }}/{{ timestamp }}"
util_shell_pkg_list_csv:  package list in csv. default: "tree"
util_shell_pkg_list: package list. default: "{{ util_shell_pkg_list_csv.split(',') }}"
util_shell_as_caller: application script caller. default: "hostname"
util_shell_process_log_fn: application log file name. default: "test.log"
util_shell_process_log_file: application log. default: "/tmp/{{ util_shell_process_log_fn }}"
util_shell_cp_file_src_offset_dir: base dir path to copy file(s) to remote. default: "/tmp"
util_shell_cp_file_src_pattern: file pattern to locate files to copy to remote . default: "*.sh"
util_shell_cp_files: . falg to copy files from local to remote. default: False
util_shell_cp_out_file_list_pattern: file pattern to locate files from remote to local. default: "*.sh"
util_shell_cp_out_file_offset_dir:. base dir path to copy file(s) from remote. default:  "{{ remote_workspace }}"
util_shell_cp_out_files: falg to copy files from remote to local. default: False
util_shell_publish_to_s3:  flag to upload a output file to aws s3. default: False
util_shell_s3_file_offset_dir:  base dir path to lookup files to be uploaded to s3. default: "{{ local_workspace }}"
util_shell_s3_object: s3 object. default: "{{ util_shell_s3_object_dir }}/{{ util_shell_build_id }}/{{ util_shell_s3_src_fn }}"
util_shell_s3_file_list_pattern: file pattern to locate files for s3 upload. default: "*.log"
util_shell_s3_bucket: s3 bucket name. default: "devops-ws"
util_shell_s3_object_dir: dir name for s3 upload. default: "others"
util_shell_build_id: build id. default: "latest"
util_shell_s3_src_file: s3 source file. default: "{{ item[0].path }}"
util_shell_s3_src_fn: s3 upload src file. default: "{{ item[1].stdout_lines[0] }}"
util_shell_delete_remote_ws: flag to delete remote workspace. default: "False"
util_shell_become: flag to execute script as sudo user.. default: "no"

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

        ---
        - hosts: all
          gather_facts: yes

          roles:
            - utilities/shell

License
-------

BSD

Author Information
------------------

Durai Govindasamy | duraivkg@gmail.com | https://www.linkedin.com/pub/durai-govindasamy/68/81a/239
