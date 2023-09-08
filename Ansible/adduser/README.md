Role Name
=========
*  in vars:
*  sudoersd: /etc/sudoers.d   - директория создания файла для доступа по ssh
*  sudo_user: True            - добавляет пользователя в группу root если True

Usage
------------
 * in host select gropu or host ip
 * use target to select host
 * select by mask " --extra-vars "target=all" --limit imac-1* "
#### для запуска на определённом хосте
ansible-playbook play.yml -i hosts --extra-vars "{
    \"target\": \"value1\",
    \"user_name\": \"value1\",
    \"password\": \"value1\"
}"

#### для запуска на определённом хосте с установкой ssh ключей
ansible-playbook play.yml -i hosts --extra-vars "{
    \"target\": \"value1\",
    \"user_name\": \"value1\",
    \"password\": \"value1\",
    \"deploy_key\": \"value1\"
}"

#### для запуска на определённом хосте смена пароля пользоватедя
ansible-playbook play.yml -i hosts --extra-vars "{
    \"target\": \"value1\",
    \"user_name\": \"value1\",
    \"change_password\": \"value1\"
}"

#### для запуска на определённом хосте с отключение пользоватедя
ansible-playbook play.yml -i hosts --extra-vars "{
    \"target\": \"value1\",
    \"disable_user\": \"value1\"
}"

#### для запуска на определённом хосте с удаление пользоватедя
ansible-playbook play.yml -i hosts --extra-vars "{
    \"target\": \"value1\",
    \"remove_user_name\": \"value1\"
}"

* Keys:
* target     - для запуска на определённом хосте
* user_name  - логин пользователя
* password   - пароль пользователя
* change_password - для смены пароля
* deploy_key - ssh key
* disable_user - отключение пароля и "/sbin/nologin"
* remove_user_name - удалить пользователя