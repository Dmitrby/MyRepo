mkdir_cctray_installer:
  file.directory:
    - name: /opt/cctray
    - user: root
    - group: root
    - file_mode: 777
    - dir_mode: 777
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

del_cctray_app:
  cmd.run:
#    - unless: test -f /usr/share/applications/cctray.desktop
    - name: sudo rm /opt/cctray/CCTray-2.1.49.16-SNAPSHOT.jar

wget_cctray_installer:
  cmd.run:
    - name: wget -O /opt/cctray/CCTray-2.1.53.1-SNAPSHOT.jar http://10.0.64.25/repos/cctray/CCTray-2.1.53.1-SNAPSHOT.jar
    - unless: test -f /opt/cctray/CCTray-2.1.53.1-SNAPSHOT.jar

chmod_cctrayjar_installer:
  file.managed:
    - name: /opt/cctray/CCTray-2.1.53.1-SNAPSHOT.jar
    - user: localadm
    - group: localadm
    - mode: 777
    - makedirs: True

  cmd.run:
    - name: wget -O /opt/cctray/cctray.ico http://10.0.64.25/repos/cctray/cctray.ico
    - unless: test -f /opt/cctray/cctray.ico

del_cctray_desktop:
  cmd.run:
#    - unless: test -f /usr/share/applications/cctray.desktop
    - name: sudo rm /usr/share/applications/cctray.desktop

create_cctray_desktop:
  file.managed:
    - name: /usr/share/applications/cctray.desktop
    - source: salt://{{ slspath }}/files/cctray.desktop
    - template: jinja
    - user: root
    - group: root
    - mode: 655

calls_cclog_chmod:
  cmd.run:
    - name: sudo chmod 777 /opt/cctray/calls.ini && sudo chmod 777 /opt/cctray/CCTrayClientLog.txt
