#!/bin/bash

PATH_TO_EXEC=$1
PATH_TO_CREDS=$2

function deploy_tomcat {
	
	TCS=(`$PATH_TO_EXEC/right_scale_api.rb $PATH_TO_CREDS/rscreds`)

	for tc in ${TCS[*]}
	do 

		echo "*********"
		echo $tc
		ssh -i ~/.ssh/rwagner-prod -o StrictHostKeyChecking=no root@$tc "/etc/init.d/tomcat6 stop; rm -rf /home/webapps/retail/releases/working/ROOT*"
		scp -i ~/.ssh/rwagner-prod $WORKSPACE/server/build/ant/ROOT.war root@$tc:/home/webapps/retail/releases/working/
		ssh -i ~/.ssh/rwagner-prod root@$tc "/etc/init.d/tomcat6 start"
		
	done

}

function deploy_dbsync {

	SYNCBOX=174.129.104.141

	tar -czf $WORKSPACE/sync.tgz $WORKSPACE/server/build
	ssh -i /usr/local/hudson/.ssh/rs-east  -o StrictHostKeyChecking=no root@$SYNCBOX "killall java; rm -rf /tmp/sync.tgz /root/scripts/sync"
	scp -i /usr/local/hudson/.ssh/rs-east $WORKSPACE/server/sync.tgz root@$SYNCBOX:/tmp
	ssh -i /usr/local/hudson/.ssh/rs-east root@$SYNCBOX "mkdir -p /root/scripts/sync; tar --extract --gunzip --strip-components 11 --file /tmp/sync.tgz --directory /root/scripts/sync; chmod +x /root/scripts/sync/dbsync.sh; nohup /root/scripts/sync/dbsync.sh cloud > /dev/null 2>&1 &"
}


function flush_memcache {

	ssh -i ~/.ssh/rwagner-prod  -o StrictHostKeyChecking=no root@75.101.168.220 "killall memcached; sleep 5 ; memcached -d -p 11211 -u memcached -m 6656 -c 1024 -P /var/run/memcached/memcached.pid -l 10.248.223.191"

}


if [ "$TOMCAT" == 1 ]
then
	deploy_tomcat
fi


if [ "$DBSYNC" == 1 ]
then
	deploy_dbsync
fi


if [ "$MEMCACHE" == 1 ]
then
	flush_memcache
fi
