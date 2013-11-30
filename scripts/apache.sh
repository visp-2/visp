#!/bin/bash

#apache.sh script servant a configurer le service apache
function usage{
#	echo " -d domain name"
#	echo ""
#	echo " -s with ssl"
#}

function create() {
	rootfs=/var/lib/lxc/apache/rootfs
	site=/etc/apache2/sites-available
	if [ $ssl -eq 1 ]
	then
		chroot $rootfs cp $site/default-ssl $site/$domain
		chroot $rootfs sed -i "s/SERVERNAME/www.$domain/g"
	else
		chroot $rootfs cp $site/default $site/$domain
		chroot $rootfs sed -i "s/SERVERNAME/www.$domain/g"
	fi
}

while getopts "d:s" opt
do
	case $opt in
		d)
		domain=$OPTARG
		s)
		ssl=1;;
		:)
		usage;;
	esac
done

create
