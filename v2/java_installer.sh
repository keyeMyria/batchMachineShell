!/bin/sh

source $(pwd)/server.conf
echo "------------ copy rpm from server : ${BASE_SERVER}"

scp root@$BASE_SERVER:/root/software/jdk-8u111-linux-x64.rpm /root/install_dir/
yum -y remove java
echo "================ install rpm"
rpm -ivh /root/install_dir/jdk-8u111-linux-x64.rpm
cat > /etc/profile.d/java.sh << HERE
	export JAVA_HOME=/usr/java/default
	export PATH=\$PATH:\$JAVA_HOME/bin
HERE

