swap_off:
  cmd.run:
    - name: swapoff /swapfile

swap_10G:
  cmd.run:
    - name: sudo fallocate -l 10G /swapfile

swap_chown:
  cmd.run:
    - name: sudo chown root:root /swapfile

swap_chmod:
  cmd.run:
    - name: sudo chmod 0600 /swapfile

swap_mkswap:
  cmd.run:
    - name: sudo mkswap /swapfile

swap_on:
  cmd.run:
    - name: sudo swapon /swapfile

swap_swappiness:
  cmd.run:
    - name: sudo sysctl -w vm.swappiness=20

swap_vfs_cache_pressure:
  cmd.run:
    - name: echo 50> /proc/sys/vm/vfs_cache_pressure

swap_vfs_cache_pressure_sysctl:
  cmd.run:
    - name: echo "vm.vfs_cache_pressure=50" >> /etc/sysctl.conf

swap_fstab:
  cmd.run:
    - name: echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab








