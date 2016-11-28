#!/bin/sh

source $(pwd)/server.conf
echo "------------ copy rpm from server : ${BASE_IP}"

scp root@${BASE_IP}:/root/software/jdk-8u111-linux-x64.rpm /root/install_dir/
yum -y remove java
echo "================ install rpm"
rpm -ivh /root/install_dir/jdk-8u111-linux-x64.rpm
cat > /etc/profile.d/java.sh << HERE
	export JAVA_HOME=/usr/java/default
	CLASS_PATH=.:\${JAVA_HOME}/lib/:\${JAVA_HOME}/jre/lib
	export PATH=\${PATH}:\${JAVA_HOME}/bin:\${JAVA_HOME}/jre/bin
HERE


