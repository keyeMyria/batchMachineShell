#!/bin/sh


if [ $# != 1 ]; then
	echo "USAGE : $0 [username]";
	echo "e.g.:$0 hadoop"
	exit 1;
fi

source $(pwd)/server.conf


auto_delete_user() {
	expect -c "set timeout -1;
		spawn ssh root@$1 \" userdel -r $2\";
		expect {
			*(yes/no)* {send -- yes\r;exp_continue;}
			*password:* {send -- \"$3\r\";exp_continue;}
			eof {exit 0;}
		}";
}

delete_user(){
	for SERVER in $SERVERS1
	do
		auto_delete_user $SERVER $1 1
	done
}


delete_user $1