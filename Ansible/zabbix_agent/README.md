Role Name
=========

Requirements for docker
------------
* usermod -aG docker zabbix
* setfacl --modify user:zabbix:rw /var/run/docker.sock

Requirements for docker
------------
* usermod -aG docker gitlab-runner
* setfacl --modify user:gitlab-runner:rw /var/run/docker.sock
