mkdir_me_installer:
  file.directory:
    - name: /opt/me
    - user: root
    - group: root
    - file_mode: 777
    - dir_mode: 777
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

wget_me_agent_installer:
  cmd.run:
    - name: wget -O /opt/me/DesktopCentral_LinuxAgent.bin http://10.0.64.25/repos/me/DesktopCentral_LinuxAgent.bin
    - unless: test -f /opt/me/DesktopCentral_LinuxAgent.bin

wget_me_json_installer:
  cmd.run:
    - name: wget -O /opt/me/serverinfo.json http://10.0.64.25/repos/me/serverinfo.json
    - unless: test -f /opt/me/serverinfo.json

me_chmod:
  cmd.run:
    - name: cd /opt/me && chmod +x /opt/me/DesktopCentral_LinuxAgent.bin

me_run_install:
  cmd.run:
    - name: cd /opt/me && ./DesktopCentral_LinuxAgent.bin -f
