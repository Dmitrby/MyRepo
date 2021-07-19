fusioninventory-agent-task-inventory:
  pkg.installed

/etc/fusioninventory/agent.cfg:
  file.managed:
    - source: salt://{{ slspath }}/files/agent.cfg
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - context:
      custom_var: "override"

/etc/systemd/system/fusioninventory-agent.service.d/50-MemoryLimit.conf:
  file.managed:
    - source: salt://{{ slspath }}/files/etc/systemd/system/fusioninventory-agent.service.d/50-MemoryLimit.conf
    - makedirs: True
    - template: jinja
    - user: root
    - group: root
    - mode: 644

/etc/cron.d/glpi.cron:
  file.managed:
    - source: salt://{{slspath}}/files/etc/cron.d/glpi.cron
    - user: root
    - group: root
    - makedirs: True
    - mode: 644

fusioninventory-agent.service: 
  service.dead: 
    - restart: False
    - enable: False
    - watch:
      - file: /etc/fusioninventory/agent.cfg

{{ sls }} systemd-reload:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/fusioninventory-agent.service.d/50-MemoryLimit.conf
