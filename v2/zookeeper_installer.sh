#!/bin/sh

source $(pwd)/server.conf
echo "********************************** $0 "

ZK_VERSION='3.4.9'

DATA_DIR="${APP_DIR}/zookeeper/data"
LOG_DIR="${APP_DIR}/zookeeper/logs"
ZK_DIR="${APP_DIR}/zookeeper"

echo "------ copy tar.gz from server ${BASE_SERVER}"

scp root@${BASE_SERVER}:/root/software/zookeeper-${ZK_VERSION}.tar.gz /root/install_dir/
mkdir -p /opt
if [ -e "${ZK_DIR}-${ZK_VERSION}" ];then
	echo "--- ${ZK_DIR}-${ZK_VERSION} exist "
	rm -rf ${ZK_DIR}-${ZK_VERSION}
fi
if [ -e "${ZK_DIR}" ];then
	echo "++++++++++++++ "
	rm -f ${ZK_DIR}
fi

tar -zxf /root/install_dir/zookeeper-${ZK_VERSION}.tar.gz -C /opt/
ln -s ${ZK_DIR}-${ZK_VERSION} ${ZK_DIR}

cp ${ZK_DIR}/conf/zoo_sample.cfg ${ZK_DIR}/conf/zoo.tmp.cfg

su - hadoop << MKDIR
	mkdir -p ${DATA_DIR};
	mkdir -p ${LOG_DIR};
	exit 0;
MKDIR

#sed -e "s/dataDir=/dataDir=${DATA_DIR}/g" ${ZK_DIR}/conf/zoo.tmp.cfg > ${ZK_DIR}/conf/zoo.cfg
#sed "s/dataDir=/dataDir=${DATA_DIR}/g" ${ZK_DIR}/conf/zoo.tmp.cfg > ${ZK_DIR}/conf/zoo.cfg
cat > ${ZK_DIR}/conf/zoo.cfg << CFG
	dataDir=${DATA_DIR}
	dataLogDir=${LOG_DIR}
CFG

count=0
for SERVER in $SERVERS1
do
	let count+=1
	cat >> ${ZK_DIR}/conf/zoo.cfg << SE
	server.${count}=slave${count}:2888:3888	
SE
done



chown -R hadoop:hadoop /opt/zookeeper*

cat > /etc/profile.d/zookeeper.sh << HE
	export ZOOKEEPER_HOME=${ZK_DIR}
	export PATH=$PATH:$ZOOKEEPER_HOME/bin:$ZOOKEEPER_HOME/conf
HE

ips=`ip addr | sed -n '/inet /{s/^.*inet \([0-9.]\+\).*$/\1/;p}'`
echo ${ips}

for one_ip in $ips
do
	ret=$(echo ${SERVERS1} | grep "${one_ip}")
	if [[ "${ret}" != "" ]];then
		idx=0
		for SERVER in ${SERVERS1} 
		do
			echo "--- ${SERVER} ==========================="
			let idx+=1
			if [[ ${one_ip} == ${SERVER} ]];then
				echo "++++++++******* ====== ${SERVER} in ${SERVERS1}"
				echo "*************** ===== ${idx} "
				cat > ${DATA_DIR}/myid << MYID
${idx}
MYID
				break;			
			fi
		done
		break;
	fi	
done

source /etc/profile
