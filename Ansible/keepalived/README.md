Role Name
=========
Usage
------------

#### для запуска установки в режиме backup с возвратом мастера
## Для мастера
ansible-playbook play.yml -i hosts --extra-vars "{
    \"target\": \"lb-infra-prod-01\",
    \"KEEPALIVE_INTERFACE\": \"ens160\",
    \"CHECK_PORT\": \"80\",
    \"KEEPALIVE_MODE\": \"backup\",
    \"VRRP_STATE\": \"MASTER\",
    \"VRRP_IPADDRESS\": \"10.144.192.130\",
    \"KEEPALIVED_PASSWORD\": \"123456\"
}"
## Для secondary
ansible-playbook play.yml -i hosts --extra-vars "{
    \"target\": \"lb-infra-prod-02\",
    \"KEEPALIVE_INTERFACE\": \"ens160\",
    \"CHECK_PORT\": \"80\",
    \"KEEPALIVE_MODE\": \"backup\",
    \"VRRP_STATE\": \"BACKUP\",
    \"VRRP_IPADDRESS\": \"10.144.192.130\",
    \"KEEPALIVED_PASSWORD\": \"123456\"
}"

#### для запуска установки в режиме балансировки без возврата мастера
CHECK_PORT = 80 or 443
## Для мастера
ansible-playbook play.yml -i hosts --extra-vars "{
    \"target\": \"lb-infra-prod-01,lb-infra-prod-02\",
    \"KEEPALIVE_INTERFACE\": \"ens160\",
    \"CHECK_PORT\": \"80\",
    \"VRRP_PROTOCOL\": \"TCP\",
    \"KEEPALIVE_MODE\": \"balance\",
    \"VRRP_IPADDRESS\": \"10.144.192.130\",
    \"NODE_01\": \"10.144.192.127\",
    \"NODE_02\": \"10.144.192.128\",
    \"KEEPALIVED_PASSWORD\": \"LIUDgwy23iuins\"
}"
