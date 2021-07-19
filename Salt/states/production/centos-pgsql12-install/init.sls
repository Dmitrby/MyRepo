centos_pgsql12_repo:
  cmd.run:
    - name: yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

centos_pgsql12_install:
  cmd.run:
    - name: yum -y install epel-release yum-utils && yum-config-manager --enable pgdg12 && yum -y install postgresql12-server postgresql12

centos_pgsql12_init:
  cmd.run:
    - name: sudo /usr/pgsql-12/bin/postgresql-12-setup initdb

centos_pgsql12_postgres_config:
  file.managed:
    - name: /var/lib/pgsql/12/data/postgresql.conf
    - source: salt://{{ slspath }}/files/postgresql.conf
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 600

centos_pgsql12_postgres_hba_config:
  file.managed:
    - name: /var/lib/pgsql/12/data/pg_hba.conf
    - source: salt://{{ slspath }}/files/pg_hba.conf
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 600

centos_pgsql12_enable:
  cmd.run:
    - name: sudo systemctl enable --now postgresql-12 && systemctl restart postgresql-12

centos_pgsql12_postgres:
  cmd.run:
    - name: sudo su - postgres -c "psql -c \"alter user postgres with password 'F,icf,y,5';\""