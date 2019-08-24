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
	read -p "[!] Do you want to proceed? [y/N]" flag
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

sudo apt-get install aircrack-ng -y
sudo apt-get install hashcat-utils -y
sudo apt-get install hcxtools -y

echo "[*] Done"
