#!/bin/bash

#apache.sh script servant a configurer le service apache

function create() {
	rootfs=/var/lib/lxc/apache/rootfs
	site=/etc/apache2/sites-available
	if [ $ssl -eq 1 ]
	then
		chroot $rootfs cp $site/default-ssl $site/$domain
		chroot $rootfs sed -i "s/SERVERNAME/www.$domain/g" $site/$domain
	else
		chroot $rootfs cp $site/default $site/$domain
		chroot $rootfs sed -i "s/SERVERNAME/www.$domain/g" $site/$domain
	fi
}

while getopts "d:s" opt
do
	case $opt in
		d)
		domain=$OPTARG;;
		s)
		ssl=1;;
		:)
		usage;;
	esac
done

create
