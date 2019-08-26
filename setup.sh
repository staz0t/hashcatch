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
	echo -e "${RED}[!] WARNING! Continuing with setup will rewrite your existing config file, db file, and your handshakes directory!${NC}"
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

if [[ `cat /etc/os-release` == *debian* ]]
then
        if [[ `dpkg -s aircrack-ng hashcat-utils hcxtools jq 2>&1` == *"not installed"* ]]
	then
		echo "${YELLOW}[!] The following packages are missing. Please ensure that you have installed them properly before starting hashcatch${NC}"
		if [[ `dpkg -s aircrack-ng 2>&1` == *"not installed"* ]]
		then
			echo -e "\taircrack-ng"
		elif [[ `dpkg -s hashcat-utils 2>&1` == *"not installed"* ]]
		then
			echo -e "\thashcat-utils"
		elif [[ `dpkg -s hcxtools 2>&1` == *"not installed"* ]]
		then
			echo -e "\thcxtools"
		elif [[ `dpkg -s jq 2>&1` == *"not installed"* ]]
		then
			echo -e "\tjq"
		fi
	else
		echo "${GREEN}[*] All necessary packages are found installed${NC}"
	fi
elif [[ `cat /etc/os-release` == *arch* ]]
then
        if [[ `pacman -Qi aircrack-ng hashcat-utils hcxtools jq 2>&1` == *"not found"* ]]
	then
		echo "${YELLOW}[!] The following packages are missing. Please ensure that you have installed them properly before starting hashcatch${NC}"
		if [[ `pacman -Qi aircrack-ng 2>&1` == *"not found"* ]]
		then
			echo -e "\taircrack-ng"
		elif [[ `pacman -Qi hashcat-utils 2>&1` == *"not found"* ]]
		then
			echo -e "\thashcat-utils"
		elif [[ `pacman -Qi hcxtools 2>&1` == *"not found"* ]]
		then
			echo -e "\thcxtools"
		elif [[ `pacman -Qi jq 2>&1` == *"not found"* ]]
		then
			echo -e "\tjq"
		fi
	else
		echo "${GREEN}[*] All necessary packages are found installed${NC}"
	fi
else
	echo "${YELLOW}[*] Please ensure that you have installed the following packages before starting hashcatch${NC}"
	echo -e "\taircrack-ng\n\thashcat-utils\n\thcxtools\n\tjq"
fi

echo "[*] Done"
