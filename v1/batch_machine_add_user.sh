#!/bin/sh

if [ $# != 1 ]; then
	echo "USAGE : $0 [username]";
	echo "e.g.:$0 hadoop"
	exit 1;
fi


SERVERS="192.168.37.134 192.168.37.136 192.168.37.137"
PASSWORD=1

BASE_SERVER=192.168.37.134


#
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
	for SERVER in $SERVERS
	do
		echo "--- begin to add user on $SERVER "
		auto_add_user $SERVER 1 $1 $1
		echo "--- end add user on $SERVER \\r"
	done
}

prepare() {
	yum install -y expect
	yum install -y interact
	yum install -y spawn
}

prepare
add_user $1

