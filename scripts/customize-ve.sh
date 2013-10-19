#!/bin/bash

# customize-template.sh

# Ce script est exécuté sur les différents VE une fois
# qu'ils sont créés pour les customizer (install apache
# ou mysql ou mail, etc)

function apache() {
	aptitude update > /dev/null
	aptitude install apache2 php5 php5-mysql > /dev/null
}

function mysql() {
	# Pour désactiver la demande de password pour le 
	# user root de MySQL
	export DEBIAN_FRONTEND=noninteractive	
	aptitude update > /dev/null
	aptitude install mysql-server > /dev/null
}

function mail() {
	export DEBIAN_FRONTEND=noninteractive	
	aptitude update > /dev/null
	aptitude install postfix dovecot-imapd > dev/null
}

function dns() {
	aptitude update > /dev/null
	aptitude install bind9 > /dev/null
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