centos_ceph.repo:
  file.managed:
    - name: /etc/yum.repos.d/ceph.repo
    - source: salt://{{ slspath }}/files/ceph.repo
    - template: jinja
    - user: root
    - group: root
    - mode: 644


centos_ceph_yum_update_install_ceph_deploy:
  cmd.run:
    - name: yum update -y && yum install ceph-deploy -y


centos_ceph_mv_ceph_deploy:
  cmd.run:
    - name: mv /etc/yum.repos.d/ceph.repo /etc/yum.repos.d/ceph-deploy.repo
