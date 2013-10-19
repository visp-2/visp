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
	cp ./scripts/firewall.sh /usr/sbin/firewall.sh
	ip=`ip addr show dev br0 | grep global | awk {'print$2'} | cut -d'/' -f-1`
	sed -i s/"HOST"/"$ip"/g /usr/sbin/firewall.sh
	echo "/usr/sbin/firewall.sh" > /etc/rc.local
	echo "exit 0" >> /etc/rc.local
}


 
