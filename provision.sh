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

	wget "https://download.jetbrains.com/idea/ideaIC-2017.3.4.tar.gz"
	tar -xzvf ideaIC-2017.3.4.tar.gz
	sudo mv idea-IC-173.4548.28 /opt/idea
	rm ideaIC-2017.3.4.tar.gz

	sudo ln -s /opt/idea/bin/idea.sh /usr/local/bin/idea.sh

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

#echo "re enable auto update apt"
#sudo systemctl start apt-daily.timer




echo "Sucecessfully Finished provisioning of vagrant."
echo "vagrant ssh to start using."







