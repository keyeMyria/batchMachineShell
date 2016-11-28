#!/bin/sh


if [ $# != 1 ]; then
	echo "USAGE : $0 xxxxx_installer.sh";
	echo "e.g.:$0 java_installer.sh"
	exit 1
fi

source $(pwd)/server.conf


for SERVER in $SERVERS1
do
	ssh root@$SERVER "mkdir -p /root/install_dir/"
	scp $1 root@$SERVER:/root/install_dir/
	scp server.conf root@$SERVER:/root/install_dir/	
	echo " ---------- $SERVER install $1 "
	ssh root@$SERVER "cd /root/install_dir; sh /root/install_dir/$1; "
done
