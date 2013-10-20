#!/bin/bash

# customize-template.sh

# Ce script est exécuté sur les différents VE une fois
# qu'ils sont créés pour les customizer (install -y apache
# ou mysql ou mail, etc)

PATH=/bin:/sbin:/usr/bin:/usr/sbin

function apache() {
	aptitude update > /dev/null
	aptitude install -y apache2 php5 php5-mysql > /dev/null
}

function mysql() {
	# Pour désactiver la demande de password pour le 
	# user root de MySQL
	export DEBIAN_FRONTEND=noninteractive	
	aptitude update > /dev/null
	aptitude install -y mysql-server > /dev/null
}

function mail() {
	export DEBIAN_FRONTEND=noninteractive	
	aptitude update > /dev/null
	aptitude install -y postfix dovecot-imapd > /dev/null

	groupadd -g 5000 vmail
	useradd -u 5000 -g vmail vmail
}

function dns() {
	aptitude update > /dev/null
	aptitude install -y bind9 > /dev/null
}

while getopts "amMd" opt
do	
	case $opt in
		a)
		apache
		;;
		m)
		mysql
		;;
		M)
		mail
		;;
		d)
		dns
		;;
	esac
done
