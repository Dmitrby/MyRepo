centos_pgsql12_postgres_config:
  file.managed:
    - name: /var/lib/pgsql/12/data/postgresql.conf
    - source: salt://{{ slspath }}/files/postgresql.conf
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 600

centos_pgsql12_timescaledb_pg_config_and_tune:
  cmd.run:
    - name: export PATH=$PATH:/usr/pgsql-12/bin  && timescaledb-tune -yes

centos_pgsql12_enable:
  cmd.run:
    - name: sudo service postgresql-12 restart

