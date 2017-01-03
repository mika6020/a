#!/usr/bin/env bash
killall screen
killall tmux
killall telegram-cli
sudo killall
RED='\033[0;31m'
NC='\033[0m'
CYAN='\033[0;36m'
echo -e "${CYAN}Install Completed! input screen ./launch.sh for run bot ${NC}"
exit

