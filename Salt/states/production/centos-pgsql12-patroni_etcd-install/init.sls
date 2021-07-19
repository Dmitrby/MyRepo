centos_pgsql12_patroni_install:
  cmd.run:
    - name: sudo yum install -y python3 && sudo python3 -m pip install --upgrade pip && yum install -y gcc python3-devel && python3 -m pip install psycopg2-binary && sudo python3 -m pip install patroni[etcd]

centos_pgsql12_patroni_dir:
  cmd.run:
    - name: sudo mkdir /etc/patroni && sudo chown postgres:postgres /etc/patroni && sudo chmod 700 /etc/patroni

centos_pgsql12_patroni_config:
  file.managed:
    - name: /etc/patroni/patroni.yml
    - source: salt://{{ slspath }}/files/patroni.yml
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 700

centos_pgsql12_patroni_service:
   file.managed:
    - name: /etc/systemd/system/patroni.service
    - source: salt://{{ slspath }}/files/patroni.service
    - template: jinja
    - user: root
    - group: root
    - mode: 644

centos_pgsql12_patroni_systemctl:
  cmd.run:
    - name: sudo systemctl daemon-reload





