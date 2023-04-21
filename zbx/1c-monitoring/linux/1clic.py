#!/usr/bin/env python3
import subprocess
import re
import json
import csv
import argparse
#import pandas as pd

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
if args.arg1 == 'Sessions':
  racInfobases = subprocess.run([path,"infobase",cluster,"summary","list"],text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout

  s=re.compile('(.*):(.*)')
  ss= (re.findall(s,rsessions))
  ss.insert(0,('0','0'))
 #replace rus name
  for i in range(len(ss)):
    if ss[i][1]== ' Администратор':
      ss[i]=(ss[i][0],"Administrator")
  datalic = {}
  for i in range(1, len(ss),49):
    datalic.setdefault("",[]).append({"session":ss[i][1],"session-id":ss[i+1][1],"infobase":ss[i+2][1],"connection":ss[i+3][1],"process":ss[i+4][1],"user-name":ss[i+5][1],"host":ss[i+6][1],"app-id":ss[i+7][1>
  # print to  json
  print((json.dumps(datalic, sort_keys=True, indent=2))[1:-1].replace('"":',""))
 ## csv output need module install (import pandas as pd) pip install pandas _OR_ apt-get install python3-pandas -and- uncomment import module
 # df = pd.read_json((json.dumps(datalic, sort_keys=True, indent=2))[1:-1].replace('"":',""))
 # print(df.to_csv())


