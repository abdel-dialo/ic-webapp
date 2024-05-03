webapp
=========

Apache installation using docker

Requirements
------------

Centos 7

Role Variables
--------------

| name                    | type   | description                                                                       | mandatory |
|-------------------------|--------|----------------------------------------------------------------------------- -----|------------|
| `external_port`         | int    | External port the httpd docker container                                           |   yes     |
| `internal_port`         | int    | Internal port the httpd docker container                                           |   yes     |
| `system_user`           | string | The system user of remote nodes                                                    |   yes     |
| `template_file`         | string |template name use for the index.html file which will be mounted in the container    |   yes     |
| `ip_prod`               | int    |IP ansible_host client2 used by the test.yml playbook                               |   yes     |
| `ip_staging`            | int    |IP ansible_host client1 used by the test.yml playbook                               |   yes     |

Dependencies
------------

n/a

Example Playbook
----------------

```yaml

- name: "Apache installation using docker"
  hosts: prod
  become: true
  roles:
    - webapp

```

License
-------

BSD

Author Information
------------------
https://github.com/abdel-dialo/mini-projet-ansible

