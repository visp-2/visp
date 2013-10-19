#!/bin/bash

aptitude update > /dev/null
for i in rsyslog
do
	aptitude install $i > /dev/null
done
