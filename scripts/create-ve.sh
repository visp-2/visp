#!/bin/bash -x

# Cette fonction permet de créer le VE client.
# Elle utilise un template (ve-template-client) et vérifie
# la somme md5 de l'archive sur le système en la comparant 
# à un fichier présent sur un autre serveur.
# On copie ensuite le répertoire obtenu et on modifie la 
# configuration (IP et hostname)

function createVe() {
	id="$1"
	ip="$2"
	domain="$3"
	lxcPath="/var/lib/lxc/"

	if [ -d "$lxcPath/ve-$id-$domain" ]
	then
		logger script create-ve.sh: le VE existe déjà
		echo "le VE existe déjà"
	elif [ -f "$lxcPath/ve-template-client.tar" ]
	then
		cd $lxcPath
		md5template=`md5sum ve-template-client.tar`
		md5origin=`curl -s www.labo-linux.be/ve-template-client.tar.md5` 
		if [ "$md5origin" == "$md5template" ]
		then
			tar -xf ve-template-client.tar
			mv ve-template-client ve-$id-$domain
			sed -i "s/172.16.255.253/$ip/g" ve-$id-$domain/config
			sed -i "s/ve-template-client/ve-$id-$domain/g" ve-$id-$domain/config

			# Création d'un lien symbolique du fichier config du VE pour autoboot
			ln -s $lxcPath/ve-$id-$domain/config /etc/lxc/auto/ve-$id-$domain
		else
			logger script create-ve.sh: Mauvais MD5 pour le template
			echo Mauvais MD5 pour le template
		fi
	fi		
}
