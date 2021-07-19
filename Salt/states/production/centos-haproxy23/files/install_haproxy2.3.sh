LAST_HAPROXY=$(wget -qO-  http://www.haproxy.org/download/2.3/src/ | egrep -o "haproxy-2.[0-9]+.[0-9]+" | head -1)
cd /usr/src/
wget http://www.haproxy.org/download/2.3/src/${LAST_HAPROXY}.tar.gz
tar xzvf ${LAST_HAPROXY}.tar.gz
yum install gcc-c++ openssl-devel pcre-static pcre-devel systemd-devel -y
cd /usr/src/${LAST_HAPROXY}
make TARGET=linux-glibc USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1 USE_CRYPT_H=1 USE_LIBCRYPT=1 USE_SYSTEMD=1
mkdir /etc/haproxy
make install
cat > /usr/lib/systemd/system/haproxy.service << 'EOL'
[Unit]
Description=HAProxy Load Balancer
After=syslog.target network.target
[Service]
Environment="CONFIG=/etc/haproxy/haproxy.cfg" "PIDFILE=/run/haproxy.pid"
ExecStartPre=/usr/local/sbin/haproxy -f $CONFIG -c -q
ExecStart=/usr/local/sbin/haproxy -Ws -f $CONFIG -p $PIDFILE
ExecReload=/usr/local/sbin/haproxy -f $CONFIG -c -q
ExecReload=/bin/kill -USR2 $MAINPID
KillMode=mixed
Restart=always
SuccessExitStatus=143
Type=notify
[Install]
WantedBy=multi-user.target
EOL
cat > /etc/haproxy/haproxy.cfg << 'EOL'
global
  log 127.0.0.1 local0
  stats socket /run/haproxy.sock mode 666 level user
  stats timeout 30s
  user haproxy
  group haproxy
  daemon

defaults
  option  dontlognull                                        # Do not log connections with no requests
  option  redispatch                                         # Try another server in case of connection failure
  option  contstats                                          # Enable continuous traffic statistics updates
  retries 3                                                  # Try to connect up to 3 times in case of failure
  timeout connect 5s                                         # 5 seconds max to connect or to stay in queue
  timeout http-keep-alive 1s                                 # 1 second max for the client to post next request
  timeout http-request 15s                                   # 15 seconds max for the client to send a request
  timeout queue 30s                                          # 30 seconds max queued on load balancer
  timeout tarpit 1m                                          # tarpit hold tim
  backlog 10000                                              #Максимальный размер лога

  balance roundrobin                                         #Какой алгоритм использовать для балансировки
  mode tcp                                                   #Режим по умолчанию для всех сценариев
  option tcplog                                              #Формат лога
  log global                                                 #Включение логирования
  timeout connect 300s
  timeout client 300s                                        #Время, после которого считается, что клиент попал в таймаут
  timeout server 300s                                        #Время, после которого считается, что сервер попал в таймаут
  default-server inter 3s rise 2 fall 3                      #Параметры сервера по умолчанию


#Этот абзац является настройкой доступа к статистики именно этой ноды haproxy
frontend stats  
  bind *:8080                                                #Где прослушивать доступ к статистике (web)
  mode http                                                  #Режим прослушки порта (Обязательно)
  log  global                                                #Включение логирования
  maxconn 1000                                               #Максимальное кол-во подключений
  stats enable                                               #Включение или отключение (закоментировать) режим статистики
  stats hide-version                                         #Версия
  stats refresh 60s                                          #Автообновление данных на страничке каждые 30 секунд
  stats show-node                                            #Показывать ноды
#  stats auth admin:password                                 #Логин и пароль для доступа на сайт статистики
  stats uri  /stats                                          #Какой адрес укзаывать в браузере, если хотим попасть на статистику, *:8080/stat
EOL
systemctl daemon-reload




