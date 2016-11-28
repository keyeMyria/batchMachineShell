#!/bin/sh

if [ `id -u` -ne 0 ];then
	echo "su $0"
	exit 1;
fi

if [ $# != 1 ];then
	echo "USAGE:$0 <hostname prefix>"
	echo "eg.: $0 mini"
	exit 1;
fi


source $(pwd)/server.conf

if [ ${TARGET_IPS} = "" ];then
	echo "set target ips in  TARGET_IPS in ${PWD}/server.conf"
fi

function auto_sethostname() {
	echo " -------------- begin to set hostname $3 for ip $1"
	expect << SHST
	spawn ssh root@$1 "hostnamectl --static set-hostname $3";
	while 1 {
		expect {
			"*re you sure you want to continue connecting (yes/no)*" {
				send "yes\n";
			}
			"*assword*" {
				send "$2\n"
			}
			eof {
				exit 0;
			}
		}
	}
SHST
}

set_hostname_batch() {
	local count=0
	local thostname=""
	for SERVER in ${SERVERS1}
	do
		let count+=1;
		hname=${1}${count}
		auto_sethostname $SERVER ${COMM_PASSWD} ${hname}
		if [ ${count} -eq 1 ];then
			thostname=${hname}
		else
			thostname="${thostname} ${hname}" 
		fi	
	done
	hostnames_exit=`grep -c "TARGET_HOSTNAMES" server.conf`
	echo " ------------- "${hostnames_exit}
	if [ ${hostnames_exit} -eq 0 ];then
		cat >> $(pwd)/server.conf << HN
TARGET_HOSTNAMES="${thostname}"
HN
	else
		sed "s/^TARGET_HOSTNAMES=\".*\"$/TARGET_HOSTNAMES=\"${thostname}\"/g" server.conf > server.conf.k
		mv -f server.conf.k server.conf
	fi
}

set_hostname_batch $1