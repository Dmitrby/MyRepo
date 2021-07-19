wget_cisco_installer:
  cmd.run:
    - name: wget -O /opt/any.sh http://10.0.64.25/repos/anyconnect/anyconnect-linux64-4.7.04056-core-vpn-webdeploy-k9.sh
    - unless: test -f /opt/any.sh

chmod_cisco_installer:
  file.managed:
    - name: /opt/any.sh
    - user: root
    - group: root
    - mode: 755

install_cisco:
  cmd.run:
    - name: bash /opt/any.sh
    - onchanges:
      - file: chmod_cisco_installer