#!/usr/bin/env bash

#stop on error
set -e
echo "If there was a problem, please correct and destroy and start provision process again, as the script only suppose to be run once..."



echo "Set timezone instead of using UTC"
echo  'Pacific/Auckland' | sudo tee /etc/timezone
sudo dpkg-reconfigure --frontend noninteractive tzdata

echo "System update"
# these prevent grub dialog
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yq

# install ubuntu desktop
echo "install ubuntu desktop"

sudo apt-get -y install ubuntu-desktop
#sudo apt-get -y install --no-install-recommends ubuntu-desktop
echo "Prepare folders..."

echo "Create apps folder under home for all installed apps"
sudo mkdir -p /home/apps
sudo chmod -R 777 /home/apps

echo "To remove libreoffice apps:"

sudo apt-get remove -y --purge libreoffice*
sudo apt-get -y clean
sudo apt-get -y autoremove

echo "To install full vim"
sudo apt-get -y install vim

if [ ! -d "/usr/lib/jvm/java-8-oracle" ]; then

	echo "Install java8"
	sudo add-apt-repository -y ppa:webupd8team/java	
	sudo apt-get update
	sudo apt-get -y upgrade
	echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
	echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
	sudo apt-get -y install oracle-java8-installer
fi

#echo "Install netbeans 8.2 at /home/apps/, this has to be done in GUI"
#echo "Must change java home as netbeans installer does not detect "
#echo "The default place it is installed to is /usr/local/netbeans-8.2"
#wget download.netbeans.org/netbeans/8.2/final/bundles/netbeans-8.2-linux.sh
#chmod +x netbeans-8.2-linux.sh
#./netbeans-8.2-linux.sh --javahome /usr/lib/jvm/java-8-oracle 

#install intelliJ Idea

if [ ! -d "/opt/idea" ]; then

	echo "Install idea"

	wget "https://download.jetbrains.com/idea/ideaIC-2018.3.1.tar.gz"
	tar -xzvf ideaIC-2018.3.1.tar.gz
	sudo mv idea-IC-183.4588.61  /opt/idea
	rm ideaIC-2018.3.1.tar.gz

	sudo ln -s /opt/idea/bin/idea.sh /usr/local/bin/idea.sh

fi

echo "Making ssh localhost passwordless for pseudodistributed mode, testing it by : ssh localhost"
if [ ! -f "/home/vagrant/.ssh/id_rsa" ]; then	
	ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
	cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
fi

if [ ! -d "/usr/local/hadoop" ]; then

	echo "Install hadoop"
	
	wget http://www-us.apache.org/dist/hadoop/common/hadoop-3.1.1/hadoop-3.1.1.tar.gz

	tar -xzvf hadoop-3.1.1.tar.gz
	sudo mv hadoop-3.1.1 /usr/local/hadoop
	rm hadoop-3.1.1.tar.gz

	echo "export HADOOP_HOME=/usr/local/hadoop" >> ~/.profile
	export HADOOP_HOME=/usr/local/hadoop
	echo "export PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin" >> ~/.profile
	export PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin

	echo "Add pseudodistributed configuration"
	mkdir -p ~/config
	mkdir -p ~/hddata
	cp -r /usr/local/hadoop/etc/hadoop  ~/config
	#copy config files 
	cp -r /vagrant/hadoopConfig/. ~/config/hadoop/


	echo "export HADOOP_CONF_DIR=/home/vagrant/config/hadoop" >> ~/.profile
	export HADOOP_CONF_DIR=/home/vagrant/config/hadoop

	echo "Add JAVA_HOME to hadoop-env.sh"
	#sed -i -e 's@${JAVA_HOME}@/usr/lib/jvm/java-8-oracle@' ~/config/hadoop/hadoop-env.sh
	echo  'export JAVA_HOME=/usr/lib/jvm/java-8-oracle' >> ~/config/hadoop/hadoop-env.sh

	echo "Formatting namenode"
	hdfs namenode -format
	echo "Copy start and stop scripts for hadoop"
	cp /vagrant/scripts/start-all.sh ~/
	cp /vagrant/scripts/stop-all.sh ~/

fi

if [ ! -d "/usr/local/spark" ]; then

	echo "Install spark"

	wget http://www-eu.apache.org/dist/spark/spark-2.4.0/spark-2.4.0-bin-hadoop2.7.tgz
	tar -xzvf spark-2.4.0-bin-hadoop2.7.tgz
	sudo mv spark-2.4.0-bin-hadoop2.7 /usr/local/spark
	rm spark-2.4.0-bin-hadoop2.7.tgz

	echo "export SPARK_HOME=/usr/local/spark" >> ~/.profile
	export SPARK_HOME=/usr/local/spark


fi


if [ ! -d "/usr/local/kafka" ]; then

	echo "Install kafka"
	
		
	wget http://www-us.apache.org/dist/kafka/1.1.1/kafka_2.11-1.1.1.tgz

	tar -xzf kafka_2.11-1.1.1.tgz
	sudo mv kafka_2.11-1.1.1 /usr/local/kafka
	rm kafka_2.11-1.1.1.tgz

	echo "export KAFKA_HOME=/usr/local/kafka" >> ~/.profile
	export KAFKA_HOME=/usr/local/kafka

fi



echo "Install git and git gui"
sudo apt-get -y install git
sudo apt-get -y install git-gui


echo "Install maven"
sudo apt-get -y install maven	

# install sbt
echo "Install sbt"

echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823
sudo apt-get update
sudo apt-get install sbt

echo "Install docker :"
echo "Issuing following to check docker version"
echo "sudo docker --version"
sudo wget -qO- https://get.docker.com/ | sh

echo "Install docker composer"
echo "Add current user to docker group"
sudo usermod -aG docker $(whoami)




#echo "re enable auto update apt"
#sudo systemctl start apt-daily.timer




echo "Sucecessfully Finished provisioning of vagrant."
echo "vagrant ssh to start using."







