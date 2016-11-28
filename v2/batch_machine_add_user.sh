#!/bin/sh

if [ $# != 2 ]; then
	echo "USAGE : $0 <username> <password>";
	echo "e.g.:$0 hadoop 123456" 
	exit 1;
fi

source $(pwd)/server.conf

# $1: hostname or ip
# $2: root password
# $3: username to be added
# $4: password for added useranme
#

function auto_add_user(){
	expect << ADD
	spawn ssh root@$1 "useradd $3; passwd $3";
	while 1 {
		expect {
			"*(yes/no)*" {
				send "yes\n"
			}
			"*assword*" {
				send "$2\n";
			}
			"*ew password*" {
				send "$4\n"
			}
			eof {
				exit;
			}
		}
	}
ADD
}

add_user() {
	for SERVER in ${SERVERS1}
	do
		echo "--- begin to add user $1 with password $2 on $SERVER "
		auto_add_user $SERVER ${COMM_PASSWD} $1 $2
		echo "--- end add user $1 with password $2 on $SERVER \\r"
	done
}

add_user $1 $2
