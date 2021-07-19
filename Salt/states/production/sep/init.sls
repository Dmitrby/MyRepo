mkdir_sep_installer:
  file.directory:
    - name: /opt/sep
    - user: root
    - group: root
    - file_mode: 777
    - dir_mode: 777
    - makedirs: True
    - recurse:
      - user
      - group
      - mode


apt_sep_installer:
  cmd.run:
    - name: sudo apt install -y libqtcore4:amd64 libqtgui4:amd64 libx11-dev libc6:i386 libx11-6:i386 libncurses5:i386 libstdc++6:i386 lib32ncurses5 lib32z1 v4l2loopback-utils

wget_sep_installer:
  cmd.run:
    - name: sudo wget -O /opt/sep/sep_linux_dpkg.zip http://10.0.64.25/repos/sep/SEP_LINUX/SEP_LINUX_DPKG.zip
    - unless: test -f /opt/sep/sep_linux_dpkg.zip

unzip_sep_installer:
  cmd.run:
    - name: sudo unzip /opt/sep/sep_linux_dpkg.zip -d /opt/sep/sep_linux_dpkg
    - unless: test -f /opt/sep/sep_linux_dpkg/install.sh

chmod_sep_installer:
  cmd.run:
    - name: sudo chmod +x /opt/sep/sep_linux_dpkg/install.sh

sep_install:
  cmd.run:
    - name: sudo bash /opt/sep/sep_linux_dpkg/install.sh -i
