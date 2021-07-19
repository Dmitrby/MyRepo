wget_zabbix-agent:
  cmd.run:
    - name: wget -O /tmp/zabbix-agent.rpm http://10.0.64.25/repos/zabbix/agent/zabbix-agent.rpm
    - unless: test -f /tmp/zabbix-agent.rpm

centos_main_zabbix-agent_install:
  cmd.run:
    - name: yum install /tmp/zabbix-agent.rpm -y

centos_zabbix-agent_config:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.conf
    - source: salt://{{ slspath }}/files/zabbix_agentd.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644

centos_main_zabbix-agent_run_and_enable:
  cmd.run:
    - name: systemctl enable zabbix-agent && systemctl start zabbix-agent