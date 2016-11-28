#!/bin/sh

source $(pwd)/server.conf

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
	spawn echo " ------------------ copy ssh key from $1 to $2 "
	spawn ssh root@$1 "ssh-copy-id $2"
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
	for ONE_IP in ${TARGET_IPS}
	do
		auto_gen_ssh_key ${ONE_IP} ${COMM_PASSWD}
	done

	for ONE_IP in ${TARGET_IPS}
	do
	# 	不起作用
	#	get_pub_key ${ONE_IP} ${BASE_SERVER} ${COMM_PASSWD}
	done

	echo '-----------------------------------------------------'
	for ONE_IP in ${TARGET_IPS}
	do
		echo " ----- put key from ${BASE_SERVER} =---== to --> ${ONE_IP} "
		put_pub_key ${BASE_SERVER} ${ONE_IP} ${COMM_PASSWD}
	done

	
}


generate_ssh_key
