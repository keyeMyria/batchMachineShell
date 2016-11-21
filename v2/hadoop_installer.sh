#!/bin/sh

source $(pwd)/server.conf
echo "********************************** $0 "

HDP_VERSION='2.6.5'

HDP_DIR="/usr/local/hadoop"

echo "------ copy tar.gz from server ${BASE_SERVER}"

scp root@${BASE_SERVER}:/root/software/hadoop-${HDP_VERSION}.tar.gz /root/install_dir/
mkdir -p /opt
if [ -e "${HDP_DIR}-${HDP_VERSION}" ];then
	echo "--- ${HDP_DIR}-${HDP_VERSION} exist "
	rm -rf ${HDP_DIR}-${HDP_VERSION}
fi
if [ -e "${HDP_DIR}" ];then
	echo "++++++++++++++ "
	rm -f ${HDP_DIR}
fi

tar -zxf /root/install_dir/hadoop-${HDP_VERSION}.tar.gz -C /opt/
ln -s ${HDP_DIR}-${HDP_VERSION} ${HDP_DIR}

hown -R hadoop:hadoop /opt/${hadoop}*

cat > /etc/profile.d/hadoop.sh << HP
	export HADOOP_HOME_HOME=${HDP_DIR}
	export PATH=${PATH}:${HADOOP_HOME}/bin
HP

source /etc/profile