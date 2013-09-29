#!/bin/bash


# Cette fonction permet de récupérer
# le numéro d'ID en fonction du dernier
# existant. On se base sur les répertoires
# présent dans "/var/lib/lxc"

function createId(){
	lxcPath="/var/lib/lxc"
	
	if [ -d "$lxcPath" ]
	then
		lastID=`ls -d $lxcPath/ve-[0-9][0-9][0-9]-*/ 2> /dev/null | awk -F \- {'print$2'} | tail -n 1`
		if [ "$lastID" == "" ]
		then
			echo 001
	
		elif [ $lastID -lt 1000 ] && [ $lastID -gt 0 ]
		then
			lastID=$((10#$lastID+1))
			printf "%03g\n" $lastID
		fi
	fi
}
