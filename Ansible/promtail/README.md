Role Name promtail
=========
From https://github.com/patrickjahns/ansible-role-promtail

### Use 
 in file play.yaml un commit needed role
 in host select gropu or host ip
 use target to select host
 select by mask " --extra-vars "target=all" --limit imac-1* "
 
```bash
ansible-playbook play.yml -i hosts --extra-vars "target=Name"
```