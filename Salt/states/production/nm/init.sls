mkdir_nomachine_installer:
  file.directory:
    - name: /opt/nomachine
    - user: root
    - group: root
    - file_mode: 777
    - dir_mode: 777
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

wget_nomachine_installer:
  cmd.run:
    - name: wget -O /opt/nomachine/nomachine_6.12.3_7_amd64.deb http://10.0.64.25/repos/nomachine/nomachine_6.12.3_7_amd64.deb
    - unless: test -f /opt/nomachine/nomachine_6.12.3_7_amd64.deb

chmod_nomachine_installer:
  cmd.run:
    - name: dpkg -i --force-depends /opt/nomachine/nomachine_6.12.3_7_amd64.deb

refile_nomachine_config_node:
  file.managed:
    - name: /usr/NX/etc/node.cfg
    - source: salt://{{ slspath }}/files/node.cfg
    - template: jinja
    - user: nx
    - group: nx
    - mode: 644

refile_nomachine_config_server:
  file.managed:
    - name: /usr/NX/etc/server.cfg
    - source: salt://{{ slspath }}/files/server.cfg
    - template: jinja
    - user: nx
    - group: nx
    - mode: 644

restart_service_nomachine:
  cmd.run:
    - name: systemctl restart nxserver
