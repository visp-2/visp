#!/bin/bash

if [ $# -eq 0 ]
then
	logger "You need to specify at least the domain name"
	echo "You need to specify at least the domain name"
	exit 1
fi

BINARY=`grep "binary path" /etc/default/visp | awk -F = {'print$2'}`

# Include des différentes fonctions nécessaires
. $BINARY/create-ip.sh
. $BINARY/id.sh
. $BINARY/create-ve.sh

id=`createId`
ip=`createIp $id`
domain=$1

createVe $id $ip $domain
