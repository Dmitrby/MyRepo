centos_haproxy1.8_install:
  cmd.run:
    - name: yum install haproxy -y

centos_haproxy1.8_service:
  cmd.run:
    - name: systemctl enable haproxy 
