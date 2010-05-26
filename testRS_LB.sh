#!/bin/sh
export PASS=0
export FAIL=0
for i in {1..100}
	do 
		if [[ `curl http://tomcat.1a.east.aws.playdom.com/retail/health | grep _INACTIVE` ]]
			then PASS=`expr $PASS + 1`
			else FAIL=`expr $FAIL + 1`
		fi
	done
