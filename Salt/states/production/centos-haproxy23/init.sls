centos_haproxy2.3_sh:
  file.managed:
    - name: /tmp/install_haproxy2.3.sh
    - source: salt://{{ slspath }}/files/install_haproxy2.3.sh
    - template: jinja
    - user: root
    - group: root
    - mode: 644

centos_haproxy2.3_install:
  cmd.run:
    - name: cd /tmp && sh install_haproxy2.3.sh

centos_haproxy2.3_service:
  cmd.run:
    - name: systemctl enable haproxy
