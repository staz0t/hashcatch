#!/bin/bash

RED='\033[0;31m'
LBLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
NC='\033[0m'

echo "[*] Starting hashcatch setup"

if [ -f config ] || [ -f db ] || [ -d handshakes ]
then
	echo -e "[!] ${RED}WARNING! Continuing with setup will rewrite your existing config file, db file, and your handshakes directory!${NC}"
	read -p "[!] Do you want to proceed? [y/N]: " flag
	flag=${flag:-"n"}
	if [[ $flag == "n" ]]
	then
		echo "[*] Exiting!"
		exit 0
	fi
fi

sudo rm -r config db handshakes
touch config &> /dev/null
touch db &> /dev/null
mkdir handshakes &> /dev/null

read -p "[*] Enter your wireless interface: " interface
echo "interface=$interface" >> config

echo -e "[!] ${YELLOW}The following packages are prerequisites for hashcatch and are about to be installed\n\taircrack-ng\n\thashcat-utils\n\thcxtools\n\tjq${NC}"
read -p "[!] Do you want to proceed? [Y/n]: " flag
flag=${flag:-"y"}
if [[ $flag == "n" ]]
then
	echo "[*] Exiting!"
	exit 0
fi

if [[ `cat /etc/os-release` == *debian* ]]
then
	sudo apt-get install aircrack-ng -y
	sudo apt-get install hashcat-utils -y
	sudo apt-get install hcxtools -y
	sudo apt-get install jq -y
elif [[ `cat /etc/os-release` == *arch* ]]
then
        sudo pacman -S aircrack-ng --noconfirm
        sudo pacman -S hashcat-utils --noconfirm
        sudo pacman -S hcxtools --noconfirm
	sudo pacman -S jq --noconfirm
fi

echo "[*] Done"
