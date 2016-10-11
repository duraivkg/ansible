users
=====

This role creates user(s), lock user(s), disable_expiration for user(s)

Requirements
------------

NA

Role Variables
--------------

am_users_groups_list_csv: group list in csv. default: "jenkins,ansible"
am_users_groups_list:  group list. default: "{{ am_users_groups_list_csv.split(',') }}" - converts comma seperated values of users to a list.
am_users_user_list_csv: user list in csv. default: "jenkins,ansible"
am_users_user_list:  user list. default: "{{ am_users_user_list_csv.split(',') }}" converts comma seperated values of users to a list.
am_users_user_shell: user default shell. default: "/bin/bash"
am_users_user_state: state of the user present/absent. default: "present"
am_users_group_state: state of the group present/absent. default: "present"
am_users_lock_user: lock the user? True/False. default: True
am_users_disable_pwd_expiry:  disable password expiry for the user? True/False. default: True

Dependencies
------------

NA

Example Playbook
----------------
    ---
    - hosts: all
      gather_facts: yes

      roles:
        - access_management/users

License
-------

BSD

Author Information
------------------

Durai Govindasamy | duraivkg@gmail.com | https://www.linkedin.com/pub/durai-govindasamy/68/81a/239
