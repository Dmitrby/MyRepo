#!/usr/bin/env python3

import requests
import urllib3
import json
import xml.etree.cElementTree as ET
import argparse
from requests.auth import HTTPBasicAuth

urllib3.disable_warnings()
# url ='https://storeonce.moskvich.ru/storeonceservices/cluster'
url ='https://storeonce.moskvich.ru/rest/alerts/count'
response = requests.get(url, verify=False, auth=HTTPBasicAuth('Admin', 'passwd'))
print(response.json())
# print((response.json()).replace(" ",""))
