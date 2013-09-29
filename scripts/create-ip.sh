#!/bin/bash

# Ce script permet de créer une adresse IP pour
# le VE du client en fonction de son ID. Elle 
# vérifie que le deuxième digit ne soit pas 
# égal à 0 sinon LXC ne permet pas de l'assigner au VE. 
# Ex: 172.16.0.01 n'est pas une IP valide

function createIp() {
	ID=$1

	if [ "$ID" -lt 1000 ] && [ "$ID" -gt 0 ] 
	then
		sdigit=`echo $ID | tail -c 3 | head -c1`
		if [ "$sdigit" == "0" ]
		then
			fdigit=`echo $ID | tail -c 5 | head -c 1`
			ldigit=`echo $ID | tail -c 2`
			echo 172.16.$fdigit.$ldigit
		else
			fdigit=`echo $ID | tail -c 5 | head -c 1`
			ldigit=`echo $ID | tail -c 2`
			echo 172.16.$fdigit.${sdigit}${ldigit}
			
		fi
	else
		logger script create-ip.sh: bad ID $ID
		echo "bad ID $ID"
	fi 
}
