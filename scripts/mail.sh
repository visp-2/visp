#!/bin/bash


function install() {
	echo todo
}


function createDomain() {
	echo todo
}

function createEmail() {
	echo todo
}

function createAlias() {
	echo todo
}

function deleteEmail() {
	echo todo
}

function deleteAlias() {
	echo todo
}


while getopts "iCDd:m:a:" opt
do
	case $opt in
		i)
		install
		;;
		C)
		shift
		if [ $opt == "D" ]
		then
			echo "You cannot use C and D parameter
