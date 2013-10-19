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
#br0
function checkbr(){
        interface="/etc/network/interfaces"

        interbr0=`cat $interface | grep "auto br0"`

        if [ "$interbr0" == "auto br0" ]
        then
		echo 1
	else
		echo 0
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
        read -p "Ex: 192.168.1.1/24 : " ipbr0

        ipbr0=`echo $ipbr0 | awk -F \/ {'print$1'}`
        maskbr0=`ipcalc $ipbr0 | grep Netmask | awk {'print$2'}`
	netbr0=`ipcalc $ipbr0 | grep Network | awk {'print$2'} | awk -F / {'print$1'}`

	# Check if the provided addresses are valid
	if [ "`ipcalc $ipbr0 | head -n1 | awk {'print$1'}`" == "INVALID" ]
	then
		echo "Invalid address for br0"
		exit 1
	fi

        check=`checkbr`
	if [ $check -eq 1 ]
	then
        	suppbr "auto br0"
	fi
        cat << EOF >> /etc/network/interfaces

auto br0
iface br0 inet static
        address $ipbr0
        netmask $maskbr0
        pre-up brctl addbr br0
        post-down brctl delbr br0

EOF

        ifdown br0 > /dev/null 2>&1

	# Check if br0 or br1 already exists
	exist=`brctl show | grep br0`
	
		if [ ! -z "$exist" ]
		then
			ip link set br0 down
			brctl delbr br0
		fi

        ifup br0
        

        ping $ipbr0 -c 1 > /dev/null
        if [ $? -eq 0 ]
        then
                echo br0 configured
        else
                echo there is some trouble for br0
                exit 1
        fi

}

function configureNatForward() {

	# add ip_forward and nat to rc.local
	
	# create exitLine to known the line number of "exit 0" 
	exitLine=$(grep -n "exit 0" /etc/rc.local | awk {'print$1'} | cut -d : -f 1 | tail -n1)
	natForward=$(grep -e "ip_forward" -e POSTROUTING /etc/rc.local)

	if [ ! -z "$natForward" ]
	then
		return
	fi
	
	if [ -z "$exitLine" ]
	then

		cat << EOF >> /etc/rc.local

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

exit 0
EOF
	else
			
		sed -i "${exitLine}d" /etc/rc.local
		cat << EOF >> /etc/rc.local

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

exit 0
EOF
	fi

}

function installCgroup() {

	cgroupFstab=`grep cgroup /etc/fstab`

	if [ -z "$cgroupFstab" ]
	then
		cat << EOF >> /etc/fstab

cgroup		/sys/fs/cgroup	cgroup	defaults	0	0

EOF
		cgroupMount=`mount | grep cgroup`
		if [ -z $cgroupMount ]
		then
			mount cgroup

			if [ $? -ne 0 ]
			then
				echo "Cannot mount cgroup"
				exit 1
			fi
		fi
	fi

}

function installTemplate() {

	ipTemplate=`echo $netbr0 | sed "s/0/253/g"`

	cp scripts/lxc-debian /usr/share/lxc/template-clients

	if [ -d /var/lib/lxc/template-client ]
	then
		read -p "The template-client already exist. Do you want to remove it? (yes/no) " yes

		while true
		do

			
			if [ -z "$yes" ]
			then
				read -p "Type yes or no " yes
			elif [ "$yes" == "yes" ]
			then
				createTemplate
				break
			elif [ "$yes" == "no" ]
			then
				echo "Ok. We will keep your template-client"
				break
			fi
		done
	else
		createTemplate
	fi

}

function createTemplate() {
	rm -rf /var/lib/lxc/template-client
	
	echo ""
	echo "Creating Template ..."
	lxc-create -n template-client -t debian > /dev/null 2>&1
	echo "Template Configured"

	sed -i "s/IPV4/$ipTemplate\/24/g" /var/lib/lxc/template-client/config
	sed -i "s/GW/$ipbr0/g" /var/lib/lxc/template-client/config
}
				
function customizeTemplate() {

	# create a rsa key for ssh to be able to execute some
	# command on the VE
	rm -rf /etc/lxc/ssh/
	mkdir /etc/lxc/ssh
	chmod 600 /etc/lxc/ssh/
	ssh-keygen -t rsa -N "" -f /etc/lxc/ssh/id_rsa-lxc > /dev/null
	
	mkdir /var/lib/lxc/template-client/rootfs/root/.ssh
	cp /etc/lxc/ssh/id_rsa-lxc.pub /var/lib/lxc/template-client/rootfs/root/.ssh/authorized_keys

	lxc-start -d -n template-client

	# install or configure some stuff
	ssh -o StrictHostKeyChecking=no -i /etc/lxc/ssh/id_rsa-lxc root@172.16.1.253 "ls -la /root"


	# Create archive
	cd /var/lib/lxc/
	tar -cf template-client.tar template-client
	md5sum template-client.tar > template-client.md5
	lxc-stop -n template-client
	rm -rf template-client
	
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
		configureNetwork
		configureNatForward
		installCgroup
		installTemplate
		customizeTemplate
		;;
	esac
done

