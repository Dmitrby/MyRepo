centos_pgbouncer_install:
  cmd.run:
    - name: yum install pgbouncer -y

centos_haproxy_conf:
  cmd.run:
    - name: mv /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.conf.backup
