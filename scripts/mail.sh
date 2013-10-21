#!/bin/bash

neutre='\e[0;m'
rougefonce='\e[0;31m'
vertclair='\e[1;32m'

function usage() {
	echo "mail.sh [-C|-D] -d domain [ [ -m mail ] [ [ -a alias ] [ -M maildrop] ] ]"
	echo
	echo -e "-C:\tcreate"
	echo -e "-D:\tdelete"
	echo -e "-d:\tdomain name"
	echo -e "-m:\tmail address"
	echo -e "-a:\talias address (use with -M)"
	echo -e "-M:\tmaildrop address (use with -a)"
	echo -e "-h:\tdisplay these help"

	exit 1
}

function mailValidator() {
	if [ $# -eq 0 ]
	then
		usage
	fi
	addressToValidate=$1	
	domainToValidate=$(echo $addressToValidate | cut -d \@ -f 2)
	result=$(whois $domainToValidate | grep -e "No whois server")
	if [ -z "$result" ]
	then
		return 0
	else
		echo
		echo -e "${rougefonce}Bad domain name for $addressToValidate${neutre}"
		echo
		exit 1
	fi
}

if [ $# -eq 0 ]
then
	usage
fi

testc=no
testd=no

while getopts ":CDd:m:a:M:h" opt
do
	case $opt in
		C)
		create=yes
		delete=no
		testc=yes
		;;
		D)
		create=no
		delete=yes
		testd=yes
		;;
		d)
		domain=$OPTARG
		;;
		m)
		mail=$OPTARG
		;;
		a)
		alias=$OPTARG
		;;
		M)
		maildrop=$OPTARG
		;;
		h)
		usage
		;;	
		:)
		usage
		;;
	esac
done



if [ "$testc" == "yes" ] && [ "$testd" == "yes" ]
then
	echo 
	echo -e "${rougefonce}You cannot create and delete a domain, email or alias"
	echo -e "at the same time${neutre}"
	echo
	usage
elif [ "$testc" == "no" ] && [ "$testd" == "no" ]
then
	echo 
	echo -e "${rougefonce}You need to use at leaste -C or -D${neutre}"
	echo
	usage
fi

completeMAddress=$(echo $mail | grep "\@")
completeAAddress=$(echo $alias | grep "\@")

if [ -z $completeMAddress ] && [ ! -z "$mail" ]
then
	mail=$mail@$domain
elif [ ! -z "$mail" ]
then
	domainOfAddress=$(echo $mail | cut -d \@ -f 2)
	if [ "$domain" != "$domainOfAddress" ]
	then
		echo
		echo -e "${rougefonce}The domain of the provided address ($domainOfAddress) doesn't match the domain name ($domain)${neutre}"
		echo
		usage
	fi
fi

if [ -z $completeAAddress ] && [ ! -z "$alias" ]
then
	alias=$alias@$domain
elif [ ! -z "$mail" ]
then
	domainOfAddress=$(echo $alias | cut -d \@ -f 2)
	if [ "$domain" != "$domainOfAddress" ]
	then
		echo
		echo -e "${rougefonce}The domain of the provided address ($domainOfAddress) doesn't match the domain name ($domain)${neutre}"
		echo
		usage
	fi
fi



if [ ! -z "$mail" ] && [ ! -z "$alias" ]
then
	echo
	echo -e "${rougefonce}You cannot use -m and -a at the same time${neutre}"
	echo 
	usage
fi

if [ ! -z "$alias" ] && [ -z "$maildrop" ]
then
	echo
	echo -e "${rougefonce}You cannot create an alias without specify a maildrop${neutre}"
	echo
	usage
fi

if [ ! -z "$domain" ] && [ -z "$alias" ] && [ ! -z $maildrop ]
then
	echo 
	echo -e "${rougefonce}-M parameter need the -a paremeter${neutre}"
	echo
	usage
fi


if [ -z "$domain" ]
then
	echo
	echo -e "${rougefonce}You need to specify at least the domain with -d parameter and -C or -D${neutre}"
	echo
	usage
fi

if [ $create == "yes" ]
then
	if [ ! -z "$domain" ] && [ ! -z "$mail" ]
	then
		mailValidator $mail
		echo "création d'une adresse mail ($mail) pour le domain $domain"
		echo "si le domaine n'existe pas, on le crée"
	elif [ ! -z "$domain" ] && [ ! -z "$alias" ]
	then
		mailValidator $maildrop
		mailValidator $alias
		echo "création d'un alias $alias vers l'adresse $maildrop"
		echo "si le domaine n'existe pas, on le crée"
	elif [ -z "$mail" ] && [ -z "$alias" ]
	then
		echo "création du domain $domain"
	fi
elif [ "$delete" == "yes" ]
then
	if [ ! -z "$domain" ] && [ ! -z "$mail" ]
	then
		echo "suppression d'une adresse mail ($mail) pour le domain $domain"
	elif [ ! -z "$domain" ] && [ ! -z "$alias" ]
	then
		echo "suppression d'un alias $alias vers l'adresse $maildrop"
	elif [ -z "$mail" ] && [ -z "$alias" ]
	then
		echo "suppression du domain $domain et des toutes ses boites"
	fi
else
	echo "erreur inconnue"
	usage
fi
