## установка ras сервиса
```
0. ras1c
1. положить в /etc/init.d/
2. chmod 755 /etc/init.d/ras1c
3. выполнить systemctl daemon-reload
4. запустить собственно службу: /etc/init.d/ras1c start
```
## настройка zabbix-agent
```
#from root user
0. mkdir /etc/zabbix/scripts  
1. копируем 1clic.py в /etc/zabbix/scripts
2. chmod + /etc/zabbix/scripts/1clic.py
3. cat /etc/zabbix/zabbix_agent2.conf | grep Include #если нет то дописывваем Include=./zabbix_agent2.d/plugins.d/*.conf
4. добавляем в cat /etc/zabbix/zabbix_agent2.d/plugins.d/1c.conf
5. systemctl restart zabbix-agent2
```

###
path="/opt/1cv8/x86_64/8.3.22.1704/rac"
###

## run parameters 
 - discovery  # возвращает данные по сессиям (число подключений, куда подключены)
 - LicenseKeys # Возвращает данные по ключам (число ключей, сколько используется)
 - Sessions # возвращвет поджробную информацию по сессиям
