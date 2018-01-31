#!/bin/bash
#This script sets up the AWS CLI and ECR (Amazon Elastic Container Registry) for use

DOCKER_COMPOSE_VERSION="1.18.0"


aws_cli_general_linux () {

cat << EOF
##########################################################
Downloading python-pip
##########################################################
EOF
sleep 1
curl -O https://bootstrap.pypa.io/get-pip.py
sleep 1

cat << EOF
##########################################################
Running python installtion script for python-pip
##########################################################
EOF

python get-pip.py --user
sleep 2

cat << EOF
##########################################################
Determining the shell
##########################################################
EOF
Shell_type=$(echo "$SHELL")

if [[ "$Shell_type" == *'bash'* ]]; then 
cat << EOF
You are using bash
EOF

sleep 1

cat << EOF
##########################################################
Showing the systemd-pah user-binaries 
This is to determine weather the operating system has a 
~/.local/bin path as not all operating systems seem to have it
##########################################################
EOF
fi

sleep 5

#for more info see here https://unix.stackexchange.com/questions/316765/which-distributions-have-home-local-bin-in-path 
system_bins=$(systemd-path user-binaries)

if [[ $system_bins == *'.local/bin'* ]]; then

cat << EOF
##########################################################
modifing your PATH variable  
##########################################################
EOF

sleep 1

export PATH=~/.local/bin:$PATH

sleep 1

cat << EOF
##########################################################
showing and loading  bash_profile into current session
##########################################################
EOF

sleep 1 

ls -al ~
source ~/.bash_profile

sleep 1

cat << EOF
##########################################################
checking pip version
##########################################################
EOF
pip --version
sleep 2

cat << EOF
##########################################################
installing AWS CLI with Pip
##########################################################
EOF
pip install awscli --upgrade --user

cat << EOF
##########################################################
checking AWS CLI version
##########################################################
EOF

sleep 1

aws --version

else

cat << EOF
##########################################################
The Operating system that you are using does not have 
a sysemd path equal of that to /.local/bin :(
it seems to be $system_bins
aborting setup
##########################################################
EOF

sleep 5

exit 0

fi

}


#need to fix this
ecs_install_general_linux () {

cat << EOF
##########################################################
This script installs AWS_ECS for installing docker contianer on AWS
##########################################################
EOF

echo "Please enter the aws acess key ID: "
read AWS_ACCESS_KEY_ID
echo "You entered: $AWS_ACCESS_KEY_ID"
echo "Please enter the aws secret key ID: "
read AWS_SECRET_ACCESS_KEY
echo "You entered: $AWS_SECRET_ACCESS_KEY"
echo "please enter a profile name: "
read PROFILE_NAME

#apt-get update -y
#apt-get install figlet
#figlet AWS ECS SCRIPT

cat << EOF
##########################################################
Downloading the binarys
##########################################################
EOF

sleep 2
sudo curl -o /usr/local/bin/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest


sleep 2 

cat << EOF
##########################################################
verifying MD5 hash of download
##########################################################
EOF

echo "$(curl -s https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest.md5) /usr/local/bin/ecs-cli" | md5sum -c -


cat << EOF
##########################################################
Apply execute permissions to the binary
##########################################################
EOF

sleep 2
sudo chmod +x /usr/local/bin/ecs-cli
ecs-cli --version

echo configure Amazon ECS cli

cat << EOF
##########################################################
Configuring Amazon ECS cli
##########################################################
EOF

sleep 2

#docs on how to install ecs-cli can be found here http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_installation.html
#docs on how to configure ecs-cli can be found here http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ECS_CLI_Configuration.html
#ec2 ECS launth types http://docs.aws.amazon.com/AmazonECS/latest/developerguide/launch_types.html

#ecs-cli configure --region us-west-2 --access-key $AWS_ACCESS_KEY_ID --secret-key $AWS_SECRET_ACCESS_KEY --cluster ecs-cli-demo
ecs-cli configure profile --profile-name $PROFILE_NAME --access-key $AWS_ACCESS_KEY_ID --secret-key $AWS_SECRET_ACCESS_KEY
ecs-cli configure --cluster DevopsCluster --default-launch-type Fargate --region us-west-2 --config-name Devopstools

}


docker_install_CentOS () {
echo "This install is for CentOS"
sleep 2
echo "unistalling any old version of docker engine that may have been on the system previously"
sleep 2
sudo yum remove docker \
                  docker-common \
                  docker-selinux \
                  docker-engine
echo "Installing required packages"
sleep 2 
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
cat << EOF
adding the stable version of the docker repository
for edge or test enter
sudo yum-config-manager --enable docker-ce-edge 
or 
sudo yum-config-manager --enable docker-ce-test
EOF
sleep 5
echo "Installing the lastest stable version of docker-ce"
sleep 2
sudo yum install docker-ce
echo "starting docker"
sleep 2
sudo systemctl start docker
echo "for production level install information see https://docs.docker.com/engine/installation/linux/docker-ce/centos/#install-docker-ce-1"
}


docker_install_ubuntu () {
echo "This install is for ubutu 16.04 LTS for other versions check https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#set-up-the-repository"
sleep 2
echo "unistalling any old version of docker engine that may have been on the system previously"
sleep 2
sudo apt-get remove docker docker-engine docker.io
echo "installing docker CE via the repository"
sudo apt-get update && apt-get upgrade -y
echo "allowing apt to use a repository over HTTPS"
sleep 2
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
echo "adding Docker’s official GPG key"
sleep 2
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
echo "installing the stable version of docker"
sleep 2
 sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce -y

cat << EOF
please note that this version of the install will always install the lastest version of Docker CE
To instal on production systems modify the code obove by running
apt-cache madison docker-ce
The above code shows which versions of docker are avalible for install for a production system dependign on which
repositories have been installed
then run 
sudo apt-get install docker-ce=<VERSION>
where you subitute the word <version> with the one avlible in the cache
hope this helps ;)
EOF
 }



check_if_docker_engine_is_installed () {
cat << EOF 
##########################################################
checking installed docker engine
##########################################################
EOF
sleep 2
docker version
}


check_if_docker_compose_is_installed () {
if [ ! -f /usr/local/bin/docker-compose ]; then
    sudo curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
else
  cat << EOF 
##########################################################
docker-compose installed
##########################################################
EOF

sleep 2

 cat << EOF 
##########################################################
checking docker-compose version
##########################################################
EOF
	sleep 2
	docker-compose version
fi
}




docker_setup_components () {
   cat << EOF 
##########################################################
checking to see docker is installed
##########################################################
EOF
   
   sleep 2
   check_if_docker_engine_is_installed

   cat << EOF 
##########################################################
checking to see if docker compose is installed
##########################################################
EOF
   
   sleep 2
   check_if_docker_compose_is_installed

}


understanding_the_OS () {
## declare an array variable
declare -a arr=("Ubuntu" "CoreOS" "CentOS")

## now loop through the above array
for i in "${arr[@]}"
do

#the line below will take what ever the value is of i is and display it in /dev/null this is a black hole sort of speak
#in which the command is executed but the user does not see the result
#so in this case only the if statement is executed &> /dev/null

   OS_CHECK="$(grep "$i" /etc/os-release)"
#   echo "$OS_CHECK"
   
   
   if [[ $OS_CHECK == *'Ubuntu'* ]]; then
    cat << EOF 
##########################################################
System OS is Ubuntu
##########################################################
EOF
   sleep 2

    cat << EOF 
##########################################################
installing the docker engine
##########################################################
EOF

   sleep 2
   docker_install_ubuntu
   docker_setup_components


   sleep 2

    cat << EOF 
##########################################################
Setting up AWS components
##########################################################
EOF
   echo "installing phython prequiste so that python get-pip.py will run please note that it can cause instability issue with pip"
   sleep 5
   sudo apt-get install python -y 
   sleep 1
   aws_cli_general_linux
   ecs_install_general_linux 
   

   elif [[ $OS_CHECK == *'CoreOS'* ]]; then
    cat << EOF 
##########################################################
System OS is CoreOS
##########################################################
EOF
   sleep 2
   docker_setup_components

    cat << EOF 
##########################################################
Setting up AWS components
##########################################################
EOF

   aws_cli_general_linux
   ecs_install_general_linux 
   
   elif [[ $OS_CHECK == *'CentOS'* ]]; then
    cat << EOF 
##########################################################
System OS is CentOS
##########################################################
EOF
   sleep 2
   docker_install_CentOS
   docker_setup_components
   
   sleep 2
   
   cat << EOF 
##########################################################
Setting up AWS components
##########################################################
EOF

   aws_cli_general_linux
   ecs_install_general_linux 

   fi
   # or do whatever with individual element of the array
done
}


cat << EOF 
##########################################################
This script is desighned to install 
Docker
Docker-Compose
AWS CLI
and 
AWC ECS CLI
on the same system
it is currently a work in progress but it is about 90% 
complete
##########################################################
EOF

sleep 10

understanding_the_OS
