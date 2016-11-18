#!/bin/sh


SERVERS="192.168.37.137 192.168.37.136 192.168.37.134"
PASSWORD=1

BASE_SERVER=192.168.37.134

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
	for SERVER in $SERVERS
	do
		shutdown_one $SERVER 1
	done
}


shutdown_all

