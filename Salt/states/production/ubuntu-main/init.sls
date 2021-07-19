centos_main_install:
  cmd.run:
    - name: yum install epel-release -y && yum install nano wget net-tools htop yum-utils iptraf -y && yum update -y

centos_main_firewalld_off:
  cmd.run:
    - name: systemctl stop firewalld && systemctl disable firewalld

centos_main_selinux_config:
  file.managed:
    - name: /etc/selinux/config
    - source: salt://{{ slspath }}/files/config
    - template: jinja
    - user: root
    - group: root
    - mode: 644

centos_main_reboot:
  cmd.run:
    - name: reboot