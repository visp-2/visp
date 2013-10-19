#!/bin/bash


. ./lib/lib-visp_install.sh
#. ./lib/lib-visp_lxc
#. ./lib/lib-visp_template


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

	esac
done
