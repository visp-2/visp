#!/bin/bash -x


. ./lib/lib-visp_install
. ./lib/lib-visp_lxc
. ./lib/lib-visp_ve


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
		installSsh
		createVe
		mkdir -p /opt/visp/bin 
		cp -r lib /opt/visp
		cp scripts/mail.sh /opt/visp/bin
		cp scripts/apache.sh /opt/visp/bin
		cp scripts/lxc-adm /opt/visp/bin
		cp conf/bashrc /root/.bashrc
		;;
	esac
done
