Role Name
=========

Ansible role to perform gradle build and upload artifacts to aws s3 bucket.

Requirements
------------

AWS access can be provided through a instance profile or using env variables (refer boto configuration settings)
echo "export AWS_ACCESS_KEY_ID=xxxx" >> /etc/profile.d/aws.sh
echo "export AWS_SECRET_ACCESS_KEY=xxxx" >> /etc/profile.d/aws.sh

Role Variables
--------------

ansible_python_interpreter:  python interpreter. default: "/usr/bin/env python"
bsg_goal: gradle build goal(s) . default: "clean install"
bsg_gradle_bin: gradle bin path. default: "/opt/local/apps/thirdparty/gradle/bin/gradle"
bsg_gradle: gradle soft link path. default: "/usr/bin/gradle"
bsg_create_sl_gradle: falg to create or skip symlink creation. default: "False"
bsg_cmd: gradle build trigger command. default: "gradle {{ bsg_goal }}"
bsg_print_build_log: flag to print build log. default: "False"
bsg_print_build_dir_contents: flag to print build dir contents. default: "False"
bsg_offset_dir: build offset dir containing build script. default: "/opt/local/provisioners/ansible/"
bsg_build_dir: build dir containing build artifacts. default: "{{ bsg_offset_dir }}/build"
bsg_distribution_dir: . distribution dir containing build artifacts. default: "{{ bsg_build_dir }}/distributions"
bsg_artifact_group_name: artifact group name. default: "ops/gradle"
bsg_artifact_name: artifact name. default: "ansible-server"
bsg_artifact_version: artifact version. default: "*"
bsg_artifact_format: artifact format. default: "tgz"
bsg_artifact_raw_src: artifact raw src file name. default: "{{ bsg_distribution_dir }}/{{ bsg_artifact_name }}-{{ bsg_artifact_version }}.{{ bsg_artifact_format }}"
bsg_artifact_enc_src: encrypted artifact file name. default: "{{ bsg_distribution_dir }}/{{ bsg_artifact_name }}.enc"
bsg_artifact_version_cmd: command to fetch artifact version from version.properties. default: "cat {{ bsg_version_file }} | awk -F= '$1==\"artifact_version\"{print $2}'"
bsg_artifact_encrypt_key: file encryption key. default: "f8kvgxREZbqg8pkeUqEj"
bsg_artifact_encrypt_cmd: file encryption command. default: "openssl enc -aes-256-cbc -k {{ bsg_artifact_encrypt_key }} -salt -in {{ bsg_distribution_dir }}/{{ bsg_artifact_name }}.tgz -out {{ bsg_artifact_enc_src }}"
bsg_artifact_master_tar_ball_cmd: command to prepare master tar ball to encrypt the artifact. . default: "cd {{ bsg_distribution_dir }} && gtar -czf {{ bsg_artifact_name }}.tgz {{ bsg_artifact_name }}-{{ bsg_artifact_version }}.{{ bsg_artifact_format }}"
bsg_artifact_publish_to_s3: falg to upload encrypted artifact to s3. default: "False"
bsg_artifact_s3_bucket: s3 bucket name. default: "artifacts-repo"
bsg_artifact_s3_dir: s3 object dir. default:  "{{ bsg_artifact_group_name }}/{{ bsg_artifact_name }}"
bsg_build_id: build id of the CI job. default: "na"
bsg_build_id_latest: dir name to store the latest artifact. default: "latest"
bsg_artifact_s3_object_latest:  s3 object name for the latest artifact. default: "{{ bsg_artifact_s3_dir }}/{{ bsg_build_id_latest }}/{{ bsg_artifact_name }}.enc"
bsg_artifact_s3_object: s3 object name for the build artifact. default:  "{{ bsg_artifact_s3_dir }}/{{ bsg_build_id }}/{{ bsg_artifact_name }}.enc"
bsg_install_pkgs: flag to install packages. default: "False"

Dependencies
------------

NA

Example Playbook
----------------

        ---
        - hosts: all
          gather_facts: yes

          roles:
            - build_service/gradle

License
-------

BSD

Author Information
------------------

Durai Govindasamy | duraivkg@gmail.com | https://www.linkedin.com/pub/durai-govindasamy/68/81a/239
