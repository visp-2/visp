#!/bin/bash


# Ce script est exécuté sur les différents VE une fois
# qu'ils sont créés pour les customizer (install -y apache
# ou mysql ou mail, etc)

PATH=/bin:/sbin:/usr/bin:/usr/sbin

function apache() {
	export DEBIAN_FRONTEND=noninteractive	
	aptitude update > /dev/null
	aptitude install -y apache2 php5 php5-mysql > /dev/null 2>&1
	mv /root/apache/apache2.conf /etc/apache2/apache2.conf
	mv /root/apache/* /etc/apache2/sites-available/
}

function mysqlfunction() {
	# Pour désactiver la demande de password pour le 
	# user root de MySQL
	export DEBIAN_FRONTEND=noninteractive	
	aptitude update > /dev/null
	aptitude install -y mysql-server > /dev/null 2>&1
	sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/my.cnf	
	service mysql restart
	mysql -u root < /root/mysql/createdb.sql
}

function mail() {
	export DEBIAN_FRONTEND=noninteractive	
	aptitude update > /dev/null
	aptitude install -y postfix postfix-mysql dovecot-imapd dovecot-mysql > /dev/null 2>&1

	# ajout du user et du groupe vmail qui ira déposer les mails (postfix)
	# et qui les lira (dovecot)
	groupadd -g 5000 vmail
	useradd -u 5000 -g vmail vmail
	
	chown vmail:vmail /home

	cp /root/mail/postfix/* /etc/postfix/
	cp -r /root/mail/dovecot/* /etc/dovecot/

}

function dns() {
	export DEBIAN_FRONTEND=noninteractive	
	aptitude update > /dev/null
	aptitude install -y bind9 > /dev/null 2>&1
}

while getopts "amMd" opt
do	
	case $opt in
		a)
		apache
		;;
		m)
		mysqlfunction
		;;
		M)
		mail
		;;
		d)
		dns
		;;
	esac
done
