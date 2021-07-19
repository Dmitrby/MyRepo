mkdir_teamviewer_installer:
  file.directory:
    - name: /opt/teamviewer
    - user: root
    - group: root
    - file_mode: 777
    - dir_mode: 777
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

wget_teamviewer_installer:
  cmd.run:
    - name: cd /opt/teamviewer && wget https://download.teamviewer.com/download/linux/teamviewer_amd64.deb && sudo dpkg -i teamviewer_amd64.deb ; rm ./teamviewer_amd64.deb && yes | sudo apt install -f
    - unless: test -f /opt/teamviewer/teamviewer_15.7.6_amd64.deb