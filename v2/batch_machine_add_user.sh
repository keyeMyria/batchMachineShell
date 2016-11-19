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
auto_add_user() {
	expect -c "set timeout -1; 
		spawn ssh root@$1 \" useradd $3; passwd $3 $4;exit;\";
		expect {
			*(yes/no)* {send -- yes\r;exp_continue;}	
			*assword:* {send -- \"$2\r\"; exp_continue;}
			eof    {exit 0;}
		
		}";
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
