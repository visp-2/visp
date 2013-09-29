#!/bin/bash


# Cette fonction permet de vérifier si une commande 
# ou un paquet existe sur le système. Elle fait une 
# vérification complète des composant nécessaire mais 
# n'installe ni ne configure quoi que ce soit.
function checkInstall() {

	cpt=0

	neutre='\e[0;m'
	rougefonce='\e[0;31m'
	vertclair='\e[1;32m'

	for i in aptitude lxc bridge-utils
	do
		package=`dpkg -l | grep ii.*$i`
		if [ ! -z "$package" ]
		then
			echo -e "${vertclair}OK${neutre}\t\t $i"
		else
			echo -e "${rougefonce}NOK${neutre}\t\t $i"
			
			# Création d'une table contenant tous les
			# paquets manquant
			toInstall[${cpt}]=$i
			let cpt+=1
		fi
	done
}

# Cette fonction permet d'installer les paquets nécessaires
# pour le bon fonctionnement de visp.
function installPackages() {

	# Cette variable permet de rendre l'installation
	# complètement silencieuse
	export DEBIAN_FRONTEND=noninteractive

	if [ "${toInstall[0]}" != aptitude ] 
	then
		echo "Updating soures"
		aptitude update > /dev/null
		echo Installing ${toInstall[@]}
		aptitude install ${toInstall[@]} -q -y > /dev/null
		
	else
		echo "Updating soures"
		apt-get update > dev/null
		echo Installing aptitude
		apt-get install aptitude -y > /dev/null
		echo Installing ${toInstall[@]}
		aptitude install ${toInstall[@]} -q -y /dev/null
	fi
}

function usage() {
	echo to do
}

function checkbr(){
	interface="/etc/network/interfaces"

	interbr0=`cat $interface | grep br0 | head -n 1 `
	interbr1=`cat $interface | grep br1 | head -n 1 `

	if [ ! -z "$interbr0" ] && [ ! -z "$interbr1" ]
	then
		echo 0
	else
		echo 1
	fi
}

function configureNetwork() {
	
	echo "IP Address for administration network (brO)"
	read -p "Ex: 192.168.1.1/24 : " netbr0
	
	echo "IP Address for clients network (br1)"
	read -p "Ex: 192.168.2.1/16 : " netbr1

	ipbr0=`echo $netbr0 | awk -F \/ {'print$1'}`
	maskbr0=`ipcalc $netbr0 | grep Netmask | awk {'print$2'}`	

	ipbr1=`echo $netbr1 | awk -F \/ {'print$1'}`
	maskbr1=`ipcalc $netbr1 | grep Netmask | awk {'print$2'}`	

	cat << EOF >> /etc/network/interfaces

auto br0
iface br0 inet static
	address $ipbr0
	netmask $maskbr0
	pre-up brctl addbr br0
	post-down brctl delbr br0

auto br1
iface br1 inet static
	address $ipbr1
	netmask $maskbr1
	pre-up brctl addbr br1
	post-down brctl delbr br1
EOF

	ifdown br0 > /dev/null 2>&1
	ifdown br1 > /dev/null 2>&1
	ifup br0 
	ifup br1

	ping $ipbr0 -c 1 > /dev/null
	if [ $? -eq 0 ]
	then
		echo br0 configured
	else
		echo there is some trouble for br0
		exit 1
	fi

	ping $ipbr1 -c 1 > /dev/null
	if [ $? -eq 0 ]
	then
		echo br1 configured
	else
		echo there is some trouble for br1
		exit 1
	fi

}


if [ $# -lt 1 ]
then
	usage
	exit 1
fi

while getopts "ci" opt
do
	case $opt in
		c)
		checkInstall
		;;
		i)
		checkInstall
		
		if [ ${#toInstall[@]} -ne 0 ]
		then
			installPackages
			checkInstall
		else
			echo "Great, no addtionnal packages to install"
		fi
		checkbr
		if [ `checkbr` -eq 1 ]
		then
			configureNetwork
		fi
		;;
	esac
done

















