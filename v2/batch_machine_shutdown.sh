#!/bin/sh


source $(pwd)/server.conf


shutdown_one() {
	expect << HERE
	spawn ssh root@$1 shutdown now;
	while 1 {
		expect {
			"*password*" {
				send "$2\n"
			}
			"*(yes/no)*" {
				send "yes\n"
			}
			eof {
				exit 0;
			}	
		}
	}
HERE
}

shutdown_all(){
	for SERVER in $SERVERS2
	do
		shutdown_one $SERVER ${COMM_PASSWD}
	done
}


shutdown_all