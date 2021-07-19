ssh_install:
  cmd.run:
    - name: sudo apt-get install ssh -y

ssh_config:
  cmd.run:
    - name: sudo sed -i 's/#Port 22/Port 2100/' /etc/ssh/sshd_config 

ssh_cinfig_2:
  cmd.run:
    - name: sudo sed -i 's/#Port 22/Port 2100/' /etc/ssh/ssh_config

