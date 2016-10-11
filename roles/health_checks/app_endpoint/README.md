Role Name
=========

Role to perform application health check

Requirements
------------

NA

Role Variables
--------------

app_end_points:
  - name: "application name" ex: "maintenance_app"
    end_point: "application end point" ex: "https://192.168.33.13/api"
    validate_certs: "creat validation flag" ex: "no"
    method: POST/GET query. ex:"POST"
    timeout: timeout in seconds. ex: 1
    status_code: status code to validate. ex: 503
    enabled: flag to enable/disable. ex: True

Dependencies
------------

NA

Example Playbook
----------------

        ---
        - hosts: all
          gather_facts: yes

          roles:
            - health_checks/app_endpoint

License
-------

BSD

Author Information
------------------

Durai Govindasamy
