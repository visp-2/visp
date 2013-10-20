#!/bin/bash


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
