#!/bin/bash

#apache.sh script servant a configurer le service apache

function create() {
	rootfs=/var/lib/lxc/apache/rootfs
	site=/etc/apache2/sites-available
	dir=/var/www
	if [  -e "$site/$domain" ]
	then
		echo "Existing domain"
	else
		chroot $rootfs mkdir "$dir/$domain"		
		if [ $ssl -eq 1 ]
		then
			chroot $rootfs cp $site/default-ssl $site/$domain
			chroot $rootfs sed -i "s#server\.#$domain\.#g" $site/$domain
			chroot $rootfs sed -i "s#DIR#"$dir/$domain"#g" $site/$domain
			chroot $rootfs sed -i "s/SERVERNAME/www.$domain/g" $site/$domain
		else
			chroot $rootfs cp $site/default $site/$domain
			chroot $rootfs sed -i "s#DIR#"$dir/$domain"#g" $site/$domain
			chroot $rootfs sed -i "s/SERVERNAME/www.$domain/g" $site/$domain
		fi
	fi
	chroot $rootfs a2ensite $domain
	chroot $rootfs service apache2 reload
}

function remove() {
	rootfs=/var/lib/lxc/apache/rootfs
	site=/etc/apache2/sites-available
	dir=/var/www
	
	chroot $rootfs rm -r "$rootfs/$dir/$domain"
	chroot $rootfs rm "$rootfs/$site/$domain"
	chroot $rootfs rm "$rootfs/etc/apache2/sites-enable/$domain"
	chroot $rootfs rm "/etc/apache2/ssl/$domain*"
	
}

function usage() {
	echo 'apache -d "Domain" [-s] -c/-d'
	echo "-s ssl active"
	echo "-c create domain"
	echo "-r remove domain"
}

ssl=0
while getopts "d:srch" opt
do
	case $opt in
		d)
		domain=$OPTARG;;
		s)
		ssl=1;;
		c)
		create;;
		r)
		remove;;
		h)
		usage;;
		*)
		usage;;
	esac
done


