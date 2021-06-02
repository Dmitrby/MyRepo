#!/bin/bash
JOB_NAME="${1}"
JOB_PARAM="${2}"

    if [[ $JOB_NAME = "Discover" ]]
    then

echo "{"
echo '    "data":['
FIRST=1

echo show jobs | bconsole  | grep -i "^  name =" | cut -d '"' -f 2 | while read line; do
    if [ $FIRST != 0 ]; then
        FIRST=0
    else
        ELEMENT="{ \"{#NAME}\":\"$DOMAIN\" },"
        echo "        $ELEMENT"
    fi
    DOMAIN=$line
done
DOMAIN=$(echo show jobs | bconsole  | grep -i "^  name =" | cut -d '"' -f 2 | tail -1)
ELEMENT="{ \"{#NAME}\":\"$DOMAIN\" }"
echo "        $ELEMENT"
echo '    ]'
echo "}"

else

 case "$1" in
        data)
         echo list job=\"$2\" | bconsole -c /etc/bareos/bconsole.conf | grep $2 | tail -1 | cut -d"|" -f5
         ;;
        filesnum)
         echo list job=\"$2\" | bconsole -c /etc/bareos/bconsole.conf | grep $2 | tail -1 | cut -d"|" -f8 | sed -r 's/[,]+//g'
         ;;
        size)
         echo list job=\"$2\" | bconsole -c /etc/bareos/bconsole.conf | grep $2 | tail -1 | cut -d"|" -f9 | sed -r 's/[,]+//g'
         ;;
        result)
         echo list job=\"$2\" | bconsole -c /etc/bareos/bconsole.conf | grep $2 | tail -1 | cut -d"|" -f10 | cut -c 2
         ;;
 esac
fi

