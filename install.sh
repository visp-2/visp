#!/bin/bash -x


# Cette fonction permet de vérifier si une commande 
# ou un paquet existe sur le système. Elle fait une 
# vérification complète des composant nécessaire mais 
# n'installe ni ne configure quoi que ce soit.
function checkInstall() {

	cpt=0

	neutre='\e[0;m'
	rougefonce='\e[0;31m'
	vertclair='\e[1;32m'

	for i in aptitude lxc bridge-utils ipcalc
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

#Cette fonction permet de verifier la presence de
#br0 ou br1 . elle renvoie
#0 si les 2 sont presents
#1 si br0 est present
#2 si br1 est present
#3 si aucun n est present

function checkbr(){
        interface="/etc/network/interfaces"

        interbr0=`cat $interface | grep "auto br0"`
        interbr1=`cat $interface | grep "auto br1"`

        if [ "$interbr0" == "auto br0" ] && [ "$interbr1" == "auto br1" ]
        then
                echo 0
        elif [ "$interbr0" == "auto br0" ] && [ "$interbr1" == "" ]
        then
                echo 1
        elif [ "$interbr0" == "" ] && [ "$interbr1" == "auto br1" ]
        then
                echo 2
        else
                echo 3
        fi
}

#Cette fonction permet de supprimer toutes les lignes br*
#present dans ../network/interfaces il suffit de passer en parametre
#le auto br* que l'on souhaite par ex: suppbr "auto br0" pour supprimer
#br0
function suppbr(){
        interface="/etc/network/interfaces"
        debut=`cat $interface | grep -n -A 5 "$1" | head -n 1 | cut -d":" -f1`
        fin=`cat $interface | grep -n -A 5 "$1" | grep post | cut -d"-" -f1`
        sed -i "$debut","$fin"d $interface
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

        check=`checkbr`
        case $check in
                0)
                        suppbr "auto br0"
                        suppbr "auto br1"
                ;;
                1)
                        suppbr "auto br0"
                ;;
		2)
                        suppbr "auto br1"
                ;;
        esac

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

















