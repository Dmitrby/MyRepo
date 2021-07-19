centos_etcd_install:
  cmd.run:
    - name: sudo yum install -y etcd

centos_etcd_config:
  file.managed:
    - name: /etc/etcd/etcd.conf
    - source: salt://{{ slspath }}/files/etcd.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644


