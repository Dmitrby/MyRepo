centos_pgsql12_timescaledb_repo:
  file.managed:
    - name: /etc/yum.repos.d/timescaledb.repo
    - source: salt://{{ slspath }}/files/timescaledb.repo
    - template: jinja
    - user: root
    - group: root
    - mode: 644

centos_pgsql12_timescaledb_install:
  cmd.run:
    - name: yum install -y timescaledb-2-postgresql-12

centos_pgsql12_timescaledb_pg_config_and_tune:
  cmd.run:
    - name: export PATH=$PATH:/usr/pgsql-12/bin  && timescaledb-tune -yes

centos_pgsql12_restart:
  cmd.run:
    - name: systemctl restart postgresql-12
