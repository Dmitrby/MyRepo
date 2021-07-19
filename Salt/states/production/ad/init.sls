#ad_apt_installer:
#  cmd.run:
#    - name: sudo apt-get -y install realmd sssd sssd-tools samba-common krb5-user packagekit samba-common-bin samba-libs adcli ntp

realmd_ad_installer:
  file.managed:
    - name: /etc/realmd.conf
    - source: salt://{{ slspath }}/files/realmd.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 644

adpass_ad_installer:
  file.managed:
    - name: /opt/.adpass
    - source: salt://{{ slspath }}/files/.adpass
    - template: jinja
    - user: root
    - group: root
    - mode: 644

Network_ad_installer:
  file.managed:
    - name: /usr/share/polkit-1/actions/org.freedesktop.NetworkManager.policy
    - source: salt://{{ slspath }}/files/org.freedesktop.NetworkManager.policy
    - template: jinja
    - user: root
    - group: root
    - mode: 644

ad_kinit:
  cmd.run:
    - name: kinit linuxad </opt/.adpass

ad_invite:
  cmd.run:
    - name: sudo realm --verbose join hq.icfed.com

sssd_ad_installer:
  file.managed:
    - name: /etc/sssd/sssd.conf
    - source: salt://{{ slspath }}/files/sssd.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 700

sssd_restart_ad_invite:
  cmd.run:
    - name: sudo service sssd restart

pam_ad_installer:
  file.managed:
    - name: /etc/pam.d/common-session
    - source: salt://{{ slspath }}/files/common-session
    - template: jinja
    - user: root
    - group: root
    - mode: 644

sudo_superadm_ad_installer:
  cmd.run:
    - name: sudo echo "superadm ALL=(ALL:ALL) ALL" >> /etc/sudoers

hostname_ad_installer:
  cmd.run:
    - name: sudo echo `cat /etc/hostname`.hq.icfed.com > /etc/hostname










