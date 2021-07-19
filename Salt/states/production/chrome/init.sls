mkdir_chrome_installer:
  file.directory:
    - name: /opt/chrome
    - user: root
    - group: root
    - file_mode: 777
    - dir_mode: 777
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

wget_chrome_installer:
  cmd.run:
    - name: wget -O /opt/chrome/google-chrome-stable_current_amd64.deb http://10.0.64.25/repos/chrome/google-chrome-stable_current_amd64.deb
    - unless: test -f /opt/chrome/google-chrome-stable_current_amd64.deb

chrome_install:
  cmd.run:
    - name: dpkg -i --force-depends /opt/chrome/google-chrome-stable_current_amd64.deb

