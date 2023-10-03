Role Name
=========
From 
https://github.com/stone-payments/ansible-rabbitmq/tree/master
https://github.com/IronCore864/ansible-rabbitmq-cluster/tree/master

### For running
in invenory file name of master node need equal rabbitmq_cluster_master

## examples
ansible-playbook play.yml -i hosts --extra-vars "{
    \"target\": \"rabbitmq-master-test,rabbitmq-node-test\",
    \"rabbitmq_cluster_master\": \"rabbitmq-master-test\"
}" 
