#!/bin/bash

#apache.sh script servant a configurer le service apache


#function usage{
#	echo " -d domain name"
#	echo ""
#	echo " -s with ssl"
#}


rootfs=/var/lib/lxc/apache/rootfs
site=/etc/apache2/site-available
chroot $rootfs mv /root/apache/apache2.conf /etc/apache2/apache2.conf
chroot $rootfs mv /root/apache/deault[-ssl] $site
if [ $ssl -eq 1 ]
then
	chroot $rootfs cp $site/default-ssl $site/$domain
	chroot $rootfs sed -i "s/SERVERNAME/www.$domain/g"
else
	chroot $rootfs cp $site/default $site/$domain
	chroot $rootfs sed -i "s/SERVERNAME/www.$domain/g"
fi

while getopts "d:s:" opt
do
	case $opt in
		d)
		domain=$OPTARGS;;
		s)
		$ssl=1;;
		:)
		usage;;
	esac
done
