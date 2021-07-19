minion_config:
  cmd.run:
    - name: sudo sed -i 's/10.0.64.118/salt.hq.icfed.com/' /etc/salt/minion 

restart_minion:
  cmd.run:
    - name: sudo systemctl restart salt-minion