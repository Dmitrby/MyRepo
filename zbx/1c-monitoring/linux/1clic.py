#!/usr/bin/env python3
import subprocess
import re
import json
import argparse
import csv
#import pandas as pd
import logging
import pygelf
from pygelf import GelfTcpHandler, GelfUdpHandler, GelfTlsHandler, GelfHttpHandler


parser = argparse.ArgumentParser()
parser.add_argument('arg1', type=str) 
args = parser.parse_args()

appID = "1CV8C", "BackgroundJob", "COMConnection", "Designer", "HTTPServiceConnection", "ODataConnection", "SrvrConsole", "WebClient"
path="/opt/1cv8/x86_64/8.3.22.1704/rac"
### get uid
uid = subprocess.run([path, "cluster","list"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True).stdout.split()[2]

### get sessions
cluster="--cluster="+uid
rsessions = subprocess.run([path, "session",cluster,"list"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True).stdout

def sessions_detail():
  racInfobases = subprocess.run([path,"infobase",cluster,"summary","list"],text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout
  b=re.compile('(.*):(.*)')
  bb= (re.findall(b,racInfobases))
# create dict infibase - id:name
  dbb={}
  for i in range(len(bb)):
    if bb[i][0]=='infobase ':
      z=bb[i][1]
      dbb[z] = bb[i+1][1]

## session to list
  s=re.compile('(.*):(.*)')
  ss= (re.findall(s,rsessions))
  ss.insert(0,('0','0'))
 #replace rus name
  for i in range(len(ss)):
    if ss[i][1]== ' Администратор':
      ss[i]=(ss[i][0],"Administrator")
# insert infobase name in to id
  for i in range(len(ss)):
    for key in dbb:
      if ss[i][1]==key:
          ss[i]=(ss[i][0],dbb[key])

  datalic = {}
  for i in range(1, len(ss),49):
    rep=(ss[i+9])[0].split(':')
    repstarted=rep[1].replace('T',' ')+':'+rep[2]+':'+(ss[i+9])[1]
    last=(ss[i+10])[0].split(':')
    lastactive=last[1].replace('T',' ')+':'+last[2]+':'+(ss[i+10])[1]

    datalic.setdefault("",[]).append({"session":ss[i][1],"session-id":ss[i+1][1],"infobase":ss[i+2][1],"connection":ss[i+3][1],"process":ss[i+4][1],"user-name":ss[i+5][1],"host":ss[i+6][1],"app-id":ss[i+7][1],"locale":ss[i+8][1],"started-at":repstarted,"last-active-at":lastactive,"hibernate":ss[i+11][1],"passive-session-hibernate-time":ss[i+12][1],"hibernate-session-terminate-time":ss[i+13][1],"blocked-by-dbms":ss[i+14][1],"blocked-by-ls":ss[i+15][1],"bytes-all":ss[i+16][1],"bytes-last-5min":ss[i+17][1],"calls-all":ss[i+18][1],"calls-last-5min":ss[i+19][1],"dbms-bytes-all":ss[i+20][1],"dbms-bytes-last-5min":ss[i+21][1],"db-proc-info":ss[i+22][1],"db-proc-took":ss[i+23][1],"db-proc-took-at":ss[i+24][1],"duration-all":ss[i+25][1],"duration-all-dbms":ss[i+26][1],"duration-current":ss[i+27][1],"duration current-dbms":ss[i+28][1],"duration-last-5min":ss[i+29][1],"duration-last-5min-dbms":ss[i+30][1],"memory-current":ss[i+31][1],"memory-last-5min":ss[i+32][1],"memory-total":ss[i+33][1],"read-current":ss[i+34][1],"read-last-5min":ss[i+35][1],"read-total":ss[i+36][1],"write-current":ss[i+37][1],"write-last-5min":ss[i+38][1],"write-total":ss[i+39][1],"duration-current-service":ss[i+40][1],"duration-last-5min-service":ss[i+41][1],"duration-all-service":ss[i+42][1],"current-service-name":ss[i+43][1],"cpu-time-current":ss[i+44][1],"cpu-time-last-5min":ss[i+45][1],"cpu-time-total":ss[i+46][1],"data-separation":ss[i+47][1],"client-ip":ss[i+48][1]})
  # print to  json
 # print((json.dumps(datalic, sort_keys=True, indent=2))[1:-1].replace('"":',""))
  sessions_data =((json.dumps(datalic, sort_keys=True, indent=2))[1:-1].replace('"":',""))
  return sessions_data
 ## csv output need module install (import pandas as pd) pip install pandas _OR_ apt-get install python3-pandas -and- uncomment import module
 # df = pd.read_json((json.dumps(datalic, sort_keys=True, indent=2))[1:-1].replace('"":',""))
 # print(df.to_csv())
##write to file
#  json_string = ((json.dumps(datalic, sort_keys=True, indent=2))[1:-1].replace('"":',""))
#  with open('json_data.json', 'w') as outfile:
#    outfile.write(json_string)


if args.arg1 == 'discovery':
  allrses= re.findall("session-id",rsessions).count("session-id")
  sleep =re.findall("yes",rsessions).count("yes")
  count = 0
  data = {}
  for  element in appID:
    res=re.findall(element,rsessions).count(element)
    key_app = "APP"
    key_slot ="Slot"
    key_sessions = "Sessions"
    key_sleep = "TotalSleep"
    key_total ="Totalsessions"
    data.setdefault("",[]).append({key_app:element,key_slot:count,key_sessions:res,key_sleep:sleep,key_total:allrses})
    count += 1
  print((json.dumps(data, sort_keys=True, indent=2))[1:-1].replace('"":',""))

###LicenseKeys
if args.arg1 == 'LicenseKeys':
  licenseqery = subprocess.run([path, "session",cluster,"list","--licenses"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True).stdout
  liccount = round((re.findall("file://C:/ProgramData/1C/licenses",licenseqery).count("file://C:/ProgramData/1C/licenses"))/2)
  liccount1 = re.findall("file://C:/ProgramData/1C/licenses",licenseqery).count("file://C:/ProgramData/1C/licenses")
  p = re.compile('full-presentation  :(.*)')
  alllic = re.findall(p,licenseqery)
  temp = []
  for x in alllic:
    if x not in temp:
      temp.append(x)
  alllic = sorted(temp, reverse=True)
  idx = 0
  datalic = {}
  for element in temp:
    z=element.split()
    if len(z) < 8:
        Keypid = element.split(",")[1].split(" ")[1].strip()
        KeyNumber = element.split(",")[2].split(" ")[1].strip()
        Usedkey= re.findall(element,licenseqery).count(element)
        LicServer = element.split(",")[0].replace('"',"").strip()
        LicOnKey = element.split(",")[2].split(" ")[3].strip()
    else:
        Keypid = element.split(",")[1].split(" ")[1].strip()
        KeyNumber = element.split(",")[4].split(" ")[1].strip()
        Usedkey = re.findall(element,licenseqery).count(element)
        LicServer = element.split(",")[2].replace('"',"").strip()
        LicOnKey = element.split(",")[4].split(" ")[3].strip()
 
 # create json
    key_pid = "Keypid"
    key_number = "KeyNumber"
    key_slot = "Slot"
    key_used = "Usedkey"
    key_server = "LicServer"
    key_onkey = "LicOnKey"
    key_total = "TotalKey"

    datalic.setdefault("",[]).append({key_pid:Keypid,key_number:KeyNumber,key_slot:idx,key_used:Usedkey,key_server:LicServer,key_onkey:LicOnKey,key_total:liccount})
    idx += 1
  print((json.dumps(datalic, sort_keys=True, indent=2))[1:-1].replace('"":',""))

##Sessions detailed info
if args.arg1 == 'sessions':
  print(sessions_detail())

if args.arg1 == 'ToGraylog':

  ss=json.loads(sessions_detail())
 
#  skip_list = (
 #           "args",
  #          "asctime",
   #         "created",
    #        "exc_info",
     #       "exc_text",
      #      "filename",
       #     "funcName",
        #    "id",
#            "levelname",
 #           "levelno",
  #          "lineno",
   #         "module",
    #        "msecs",
     #       "message",
      #      "msg",
       #     "name",
        #    "pathname",
         #   "process",
#            "processName",
 #           "relativeCreated",
  #          "thread",
   #         "threadName",
    #      )
 # data={}
 # zz=[]
 # for i in range(len(ss)):
  #  zz.append(data)
   # for key, value in ss[i].items():
    #  data["version"] = "1"
     # data["serverhost"] = "1C-DOCFLOW-APP-CLUSTERDATA" 
     # if key not in skip_list and not key.startswith("_"):
      #  data["_%s" % key] = value.strip()
#  print(zz)
  SERVER_URL = "http://graylog.moskvich.ru:12201/gelf"

  class ContextFilter(logging.Filter):
    def filter(self, record):
      record.username = ss[i]['user-name']
      record.app_id = ss[i]['app-id']
      record.blocked_by_dbms = ss[i]['blocked-by-dbms']
      record.blocked_by_ls = ss[i]['blocked-by-ls']
      record.bytes_all = ss[i]['bytes-all']
      record.bytes_last_5min = ss[i]['bytes-last-5min']
      record.calls_all = ss[i]['calls-all']
      record.calls_last_5min = ss[i]['calls-last-5min']
      record.client_ip = ss[i]['client-ip']
      record.cpu_time_current = ss[i]['cpu-time-current']
      record.cpu_time_last_5min = ss[i]['cpu-time-last-5min']
      record.cpu_time_total = ss[i]['cpu-time-total']
      record.current_service_name = ss[i]['current-service-name']
      record.data_separation = ss[i]['data-separation']
      record.db_proc_info = ss[i]['db-proc-info']
      record.db_proc_took = ss[i]['db-proc-took']
      record.db_proc_took_at = ss[i]['db-proc-took-at']
      record.dbms_bytes_all = ss[i]['dbms-bytes-all']
      record.dbms_bytes_last_5min = ss[i]['dbms-bytes-last-5min']
      record.duration_current_dbms = ss[i]['duration current-dbms']
      record.duration_all = ss[i]['duration-all']
      record.duration_all_dbms = ss[i]['duration-all-dbms']
      record.duration_all_service = ss[i]['duration-all-service']
      record.duration_current = ss[i]['duration-current']
      record.duration_current_service = ss[i]['duration-current-service']
      record.duration_last_5min = ss[i]['duration-last-5min']
      record.duration_last_5min_dbms = ss[i]['duration-last-5min-dbms']
      record.duration_last_5min_service = ss[i]['duration-last-5min-service']
      record.hibernate = ss[i]['hibernate']
      record.hibernate_session_terminate_time = ss[i]['hibernate-session-terminate-time']
      record.host = ss[i]['host']
      record.infobase = ss[i]['infobase']
      record.last_active_at = ss[i]['last-active-at']
      record.locale = ss[i]['locale']
      record.memory_current = ss[i]['memory-current']
      record.memory_last_5min = ss[i]['memory-last-5min']
      record.memory_total = ss[i]['memory-total']
      record.passive_session_hibernate_time = ss[i]['passive-session-hibernate-time']
      record.read_current = ss[i]['read-current']
      record.read_last_5min = ss[i]['read-last-5min']
      record.read_total = ss[i]['read-total']
      record.session = ss[i]['session']
      record.session_id = ss[i]['session-id']
      record.started_at = ss[i]['started-at']
      record.write_current = ss[i]['write-current']
      record.write_last_5min = ss[i]['write-last-5min']
      record.write_total = ss[i]['write-total']
 #     record.source = '1C-DOCFLOW-APP-CLUSTERDATA'

      return True

  for i in range(len(ss)):
    logging.basicConfig(level=logging.DEBUG)
    logger = logging.getLogger()
    logger.addFilter(ContextFilter())
    handler = GelfUdpHandler(host='graylog.moskvich.ru', port=12201,compress=True, debug=True, include_extra_fields=True)
    logger.addHandler(handler)
    logger.debug(ss[i])
