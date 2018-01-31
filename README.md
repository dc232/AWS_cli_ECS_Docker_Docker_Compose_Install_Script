# AWS_cli_ECS_Docker_Docker_Compose_Install_Script
This script is designed to install Docker Docker Compose AWS Cli ECS Cli on the same machine
Please note that this script is stilla work in progress and ahould work on Ubuntu and CoreOS still need to test on CentOS

Please also note that it is better to run this script as a normal user as oppose to root this insures the binarys needed to run AWS Cli are installed properly

To run simply add execution bit to script so 
chmod +x 
AWS_CLI_ECS_Docker_installer.sh

And then run via 
./AWS_CLI_ECS_Docker_installer.sh

Enviroment vars that can be changed
DOCKER_COMPOSE_VERSION="1.18.0"

