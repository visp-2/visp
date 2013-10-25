#!/bin/bash

function start() {

	# Define VE's IP
	apache=172.16.1.%WEB
	mysql=172.16.1.%SQL
	dns=172.16.1.%DNS
	mail=172.16.1.%MAIL
	host=eth0

	# Flush all rules
	iptables -t nat -F
	iptables -t filter -F
	
	# Routing
	echo 1 > /proc/sys/net/ipv4/ip_forward

	# NAT for outgoing trafic
	iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

	#=============#
	#  NAT to VE  #
	#=============#
	
	# HTTP & HTTPs
	iptables -t nat -A PREROUTING -p tcp -i $host --dport 80 -j DNAT --to-destination $apache:80
	iptables -t nat -A PREROUTING -p tcp -i $host --dport 443 -j DNAT --to-destination $apache:433

	# SMTP, SMTPs, IMAP, IMAPs, POP3, POP3s
	iptables -t nat -A PREROUTING -p tcp -i $host --dport 25 -j DNAT --to-destination $mail:25
	iptables -t nat -A PREROUTING -p tcp -i $host --dport 465 -j DNAT --to-destination $mail:465
	iptables -t nat -A PREROUTING -p tcp -i $host --dport 143 -j DNAT --to-destination $mail:143
	iptables -t nat -A PREROUTING -p tcp -i $host --dport 993 -j DNAT --to-destination $mail:993
	iptables -t nat -A PREROUTING -p tcp -i $host --dport 110 -j DNAT --to-destination $mail:110
	iptables -t nat -A PREROUTING -p tcp -i $host --dport 995 -j DNAT --to-destination $mail:995

	# DNS
	iptables -t nat -A PREROUTING -p tcp -i $host --dport 53 -j DNAT --to-destination $dns:53

}

function stop() {

	iptables -t nat -F
	iptables -t filter -F

}

case $1 in
	start)
	start
	;;
	stop)
	stop
	;;
	*)
	echo "Bad Use"
	;;
esac
