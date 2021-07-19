mkdir_skype_installer:
  file.directory:
    - name: /opt/skype
    - user: root
    - group: root
    - file_mode: 777
    - dir_mode: 777
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

wget_skype_installer:
  cmd.run:
    - name: wget -O /opt/skype/skypeforlinux-64.deb http://10.0.64.25/repos/skypeforlinux/skypeforlinux-64.deb   
    - unless: test -f /opt/skype/skypeforlinux-64.deb

skype_install:
  cmd.run:
    - name: sudo dpkg -i /opt/skype/skypeforlinux-64.deb