pm-utils_installer:
  cmd.run:
    - name: sudo apt install pm-utils -y

logind_installer:
  file.managed:
    - name: /etc/systemd/logind.conf
    - source: salt://{{ slspath }}/files/logind.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644

screensaver_off:
  cmd.run:
    - name: sudo gsettings set org.gnome.desktop.screensaver lock-enabled false

pm-utils_restar:
  cmd.run:
    - name: sudo reboot now