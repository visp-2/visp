#!/bin/bash

apache=172.16.1.1
mysql=172.16.1.2
dns=172.16.1.4
mail=172.16.1.3
host=eth0

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -t nat -A PREROUTING -p tcp -i $host --dport 80 -j DNAT --to-destination $apache:80
iptables -t nat -A PREROUTING -p tcp -i $host --dport 443 -j DNAT --to-destionation $apache:433
iptables -t nat -A PREROUTING -p tcp -i $host --dport 25 -j DNAT --to-destination $mail:25
iptabltes -t nat -A PREROUTING -p tcp -i $host --dport 53 -j DNAT --to-destionation $dns:53
