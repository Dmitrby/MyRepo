ubuntu_autoclean:
  cmd.run:
    - name: sudo apt autoclean

ubuntu_update_upgrade:
  cmd.run:
    - name: sudo apt update && sudo apt upgrade -y