autoupdate_off_installer:
  file.managed:
    - name: /etc/apt/apt.conf.d/20auto-upgrades
    - source: salt://{{ slspath }}/files/20auto-upgrades
    - template: jinja
    - user: root
    - group: root
    - mode: 644









