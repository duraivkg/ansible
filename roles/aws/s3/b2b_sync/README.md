Role Name
=========

A brief description of the role goes here.

Requirements
------------

AWS access can be provided through a instance profile or using env variables (refer boto configuration settings)
echo "export AWS_ACCESS_KEY_ID=xxxx" >> /etc/profile.d/aws.sh
echo "export AWS_SECRET_ACCESS_KEY=xxxx" >> /etc/profile.d/aws.sh

Role Variables
--------------

local_workspace_param: local workpace base path. default: /tmp/ansible_ws/aws/s3/b2b_sync
remote_workspace_param: remote workpace base path. default: /opt/local/ansible_ws/aws/s3/b2b_sync
local_workspace: local workspace path.  default: "{{ local_workspace_param }}/{{ timestamp }}"
remote_workspace: remote workspace path.  default: "{{ remote_workspace_param }}/{{ timestamp }}"
global_log_dir: global log dir for log processing by splunk/elk default: "/opt/local/logs/ansible/"
global_log_file:  global log file for log processing  by splunk/elk default:  "{{ global_log_dir }}/{{ s3_sync_bs_log_fn }}"
build_id: build id, if the execution is driven by an orchestrator's (Jenkins) wf. default: "na"
app_user: app user name. default: "ansible"
app_group: app user group. default: "ansible"
s3_sync_bs: s3 bootstrap sync script name. defaut: "aws_s3_sync_b2b.sh"
s3_sync_bs_arg_src_bucket: s3 bootstrap sync script arg - src_bucket_name default: "sync-test-src"
s3_sync_bs_arg_tgt_bucket: s3 bootstrap sync script arg - tgt_bucket_name default: "sync-test-tgt"
s3_sync_bs_arg_tgt_info_mode: s3 bootstrap sync script arg - tgt bucket info mode default: "dynamic"
s3_sync_bs_arg_sync_forks: s3 bootstrap sync script arg - sync_forks - parallel processing threads. default: "2"
s3_sync_bs_arg_tgt_bucket_dir:  s3 bootstrap sync script arg - tgt_bucket_dir - tgt_bucket_dir to sync .. if any. default: "NA"
s3_sync_bs_arg_sleep_timer: s3 bootstrap sync script arg - sync_forks - sleep_timer for monitoring the parallel shell executions. default: "15"
s3_sync_bs_arg_extra_vars:  s3 bootstrap sync script arg - extra_vars - any extra vars for boot strap script default: "NA"
s3_sync_bs_arg_wait: s3 bootstrap sync script arg - wait - wait for the parallel processing scripts to finish or just launch the parallel processing scripts and exit. default: "yes"
s3_sync_bs_arg_tag_archive: s3 bootstrap sync script arg - tag_archive -  tag name in src bucket contaaining target bucket name. default: "archive_target"
s3_sync_bs_arg_workspace: s3 bootstrap sync script arg - workspace - bootstrap script workspace. default: "{{ remote_workspace }}"
s3_sync_bs_arg_aws_caller: s3 bootstrap sync script arg - aws_caller - aws cli bin info default: "aws"
s3_sync_bs_caller: s3 bootstrap sync script arg - bs_caller - bootstrap script caller. default: "sh {{ s3_sync_bs }} --workspace {{ s3_sync_bs_arg_workspace }} --src_bucket {{ s3_sync_bs_arg_src_bucket }} --target_bucket {{ s3_sync_bs_arg_tgt_bucket }} --target_info_mode {{ s3_sync_bs_arg_tgt_info_mode }} --sync_forks {{ s3_sync_bs_arg_sync_forks }} --target_bucket_dir {{ s3_sync_bs_arg_tgt_bucket_dir }}  --sleep_timer {{ s3_sync_bs_arg_sleep_timer }} --extra_vars {{ s3_sync_bs_arg_extra_vars }} --wait {{ s3_sync_bs_arg_wait }} --tag_archive {{ s3_sync_bs_arg_tag_archive }} --aws_caller {{ s3_sync_bs_arg_aws_caller }}"
s3_sync_bs_log_fn: s3 bootstrap sync script arg - log_fn - bootstrap script log file name. default: "aws_s3_sync_b2b.log"
s3_sync_bs_log_file: s3 bootstrap sync script arg - log_file - bootstrap script log file.  default: "{{ s3_sync_bs_arg_workspace }}/aws_s3_sync_b2b/logs/{{ s3_sync_bs_log_fn }}"
s3_sync_bs_global_caller: s3 bootstrap sync script arg - global_caller - bootstrap script caller for global vars driven paramemeters. default: "sh {{ s3_sync_bs }} --src_bucket {{ item.bs_arg_src_bucket }} --target_bucket {{ item.bs_arg_tgt_bucket }} --target_info_mode {{ item.bs_arg_tgt_info_mode }} --sync_forks {{ item.bs_arg_sync_forks }} --target_bucket_dir {{ item.bs_arg_tgt_bucket_dir }}  --sleep_timer {{ item.bs_arg_sleep_timer }} --extra_vars {{ item.bs_arg_extra_vars }} --wait {{item.bs_arg_wait }} --tag_archive {{ item.bs_arg_tag_archive }} --aws_caller {{ item.bs_arg_aws_caller }}"
s3_sync_b2b_list_global: s3 bootstrap sync script arg - global_caller - token flag for enabling/disabling bootstrap script caller for global vars driven paramemeters. default: "False"


Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

    ---
    - hosts: localhost
      remote_user: root
      roles:
        - aws/s3/b2b_sync

License
-------

BSD

Author Information
------------------

Durai Govindasamy | duraivkg@gmail.com | https://www.linkedin.com/pub/durai-govindasamy/68/81a/239
