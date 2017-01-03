#!/usr/bin/env bash
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install tmux
sudo apt-get install luarocks
sudo apt-get install screen
sudo apt install redis-server
sudo apt-get install libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev lua-socket lua-sec lua-expat libevent-dev make unzip git redis-server autoconf g++ libjansson-dev libpython-dev expat libexpat1-dev
sudo apt-get update
sudo apt-get install
sudo apt-get install upstart-sysv
sudo apt-get install nohup-server
sudo apt-get install libreadline-dev
sudo apt-get install libconfig-dev 
sudo apt-get install libssl-dev 
sudo apt-get install lua5.2 
sudo apt-get install liblua5.2-dev 
sudo apt-get install lua-socket 
sudo apt-get install lua-sec 
sudo apt-get install lua-expat 
sudo apt-get install libevent-dev 
sudo apt-get install make 
sudo apt-get install unzip 
sudo apt-get install git 
sudo apt-get install redis-server 
sudo apt-get install autoconf 
sudo apt-get install g++ 
sudo apt-get install libjansson-dev 
sudo apt-get install libpython-dev 
sudo apt-get install expat libexpat1-dev 
sudo apt-get install ppa-purge 
sudo apt-get install python3-pip 
sudo apt-get install python3-dev
sudo apt-get install software-properties-common
sudo apt-get install python-software-properties
sudo apt-get install gcc-6
sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get upgrade
sudo apt-get dist-upgrade
sudo ppa-purge
sudo pip3 install redis
sudo service redis-server restart
chmod +x launch.sh
./launch.sh install
RED='\033[0;31m'
NC='\033[0m'
CYAN='\033[0;36m'
echo -e "${CYAN}Install Completed! input ./launch.sh for run bot ${NC}"
exit

