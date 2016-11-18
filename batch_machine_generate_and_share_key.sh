#!/bin/sh

SERVERS="192.168.37.134 192.168.37.136 192.168.37.137"
PASSWORD=1

BASE_SERVER=192.168.37.134

#
# $1:hostname or ip
# $2:remote root password
#
auto_gen_ssh_key() {
	expect << HERE
	spawn ssh root@$1 ssh-keygen -t rsa
	while 1 {
		expect {
			"*password*" {
				send "$2\n"
			}
			"*(yes/no)*" {
				send "yes\n"
			}
			"*nter file in which to save the key*" {
				send "\n"
			}		
			"*nter same passphrase again*" {
				send "\n"
			}
			"*(y/n)*" {
				send "n\n"
			}
			"*nter passphrase (empty for no passphrase)*" {
				send "\n"
			}
			eof {
				exit 0
			}
		}
	}
HERE
}

function get_pub_key() {
	expect << GETKEY
	spawn ssh root@$1 ssh-copy-id $2
	while 1 {
		expect {
			"*password*" {
				send "$3\n"
			}
			"*re you sure you want to continue connecting (yes/no)*" {
				send "yes\n"
			}
			eof {
				exit 0;
			}
		}
	}
GETKEY
}


function put_pub_key() {
	expect << SE
	spawn ssh-copy-id $2
	while 1 {
		expect {
			"*password*" {
				send "$3\n"
			}
			"*yes/no*" {
				send "yes\n"
			}
			eof {
				exit 0;
			}
		}
	}
SE
}

function generate_ssh_key() {
	for SERVER in $SERVERS
	do
		auto_gen_ssh_key $SERVER 1		
		get_pub_key $SERVER $BASE_SERVER 1
	done
	
	for SERVER in $SERVERS
	do
		put_pub_key $BASE_SERVER $SERVER 1
	done
}


generate_ssh_key


