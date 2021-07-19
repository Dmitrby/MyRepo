lldpd_install:
  pkg.installed:
    - name: lldpd

lldpd.service:
  service.running:
    - name: lldpd
    - enable: True
    - restart: True