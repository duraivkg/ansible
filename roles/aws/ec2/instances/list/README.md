list
====

Role to list ec2 instances and write those to a file. This role will be helpful when we need to implement deployment workflows in aws.

Requirements
------------

AWS access can be provided through a instance profile or using env variables (refer boto configuration settings)
echo "export AWS_ACCESS_KEY_ID=xxxx" >> /etc/profile.d/aws.sh
echo "export AWS_SECRET_ACCESS_KEY=xxxx" >> /etc/profile.d/aws.sh

Role Variables
--------------

ansible_python_interpreter: python path. default: "/usr/bin/env python"
local_workspace_param: local workpace base path. default: /tmp/ansible_ws/aws/instances/list
local_workspace: local workspace path.  default: "{{ local_workspace_param }}/{{ timestamp }}"
ec2_ins_list_domain_name: domain name of the instance (part of fqdn). default: ".qa.com"
ec2_ins_list_dyn_host_file_tpl: Jinja host file template. default: "dynamic_inventory.j2"
ec2_ins_list_dyn_host_file_dest: generated host file default: "{{ local_workspace}}/dynamic_inventory"
ec2_ins_list_install_modules: install ec2 packages? true/falsedefault: false
clean_ws: clean the workspace true/false. default: false
ec2_ins_list_region_csv:  ec2 region list in csv. default: "us-east-1,us-west-1,us-west-2,ap-northeast-2,ap-southeast-1,ap-southeast-2,ap-northeast-1,eu-central-1,eu-west-1,sa-east-1"
ec2_ins_list_region: ec2 region list default: "{{ ec2_ins_list_region_csv.split(',') }}"
ec2_ins_list_host_name_pattern_csv: hostname pattern in csv. default: "*apiproxy*,*stable*,*continuous*"
ec2_ins_list_host_name_pattern: "{{ ec2_ins_list_host_name_pattern_csv.split(',') }}"
ec2_ins_list_pkg_list_csv: packages to install in csv. default: "python-boto"
ec2_ins_list_pkgs: list of packages to install. default: "{{ ec2_ins_list_pkg_list_csv.split(',') }}"
ec2_ins_list_ins_state_csv: ec2 instance state in csv. default: "running"
ec2_ins_list_ins_state: ec2 instance state list. default: "{{ ec2_ins_list_ins_state_csv.split(',') }}"

Dependencies
------------

NA

Example Playbook
----------------

        ---
        - hosts: all
          gather_facts: yes

          roles:
            - aws/ec2/instances/list

License
-------

BSD

Author Information
------------------

Durai Govindasamy | duraivkg@gmail.com | https://www.linkedin.com/pub/durai-govindasamy/68/81a/239
