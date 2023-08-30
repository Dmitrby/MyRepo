#!/bin/bash

#variables
dir="${1}"    # certs directory
PARAM1="${2}" # actions

if [[ $PARAM1 = "Discover" ]]  # Discovery serts names
then

CERTS=$(find $dir -name *.crt -exec basename {} \;)

echo "{"
echo '    "data":['
FIRST=1

echo $CERTS  | tr ' ' '\n '|sort  | while read line; do
    if [ $FIRST != 0 ]; then
        FIRST=0
    else
        ELEMENT="{ \"{#NAME}\":\"$DOMAIN\" },"
        echo "        $ELEMENT"
    fi
    DOMAIN=$line
done
DOMAIN=$(echo $CERTS | tr ' ' '\n '|sort | tail -1)
ELEMENT="{ \"{#NAME}\":\"$DOMAIN\" }"
echo "        $ELEMENT"
echo '    ]'
echo "}"

else     # get expiration date by name

#openssl x509 -enddate -noout -in $dir/$PARAM1

CERTDIR=$(find $dir -name $PARAM1)
expiryDays=$(( ($(date -d "$(openssl x509 -enddate -noout -in $CERTDIR | cut -d= -f2)" '+%s') - $(date '+%s')) / 86400 ))
echo $expiryDays
fi

