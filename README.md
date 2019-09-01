# hashcatch
Hashcatch deauthenticates clients connected to all nearby WiFi networks and tries to capture the handshakes. It can be used in any linux device including Raspberry Pi and Nethunter devices so that you can capture handshakes while walking your dog

Written by [@SivaneshAshok](https://twitter.com/sivaneshashok)

#### PoC of hashcatch (running with a couple of WiFi networks within range)
[![hashcatch PoC](https://asciinema.org/a/AQEzLSxo7teoxPzNSJfwn4UNQ.svg)](https://asciinema.org/a/AQEzLSxo7teoxPzNSJfwn4UNQ)

#### Install from source
1. ```git clone https://github.com/staz0t/hashcatch```
2. Install the prerequisites and ensure that they are working properly
3. [optional] Add the hashcatch directory to your PATH
4. ```./hashcatch --setup```
5. Answer the prompts
6. And done!

#### Install using packages
1. Download the respective package for your distribution from [releases](https://github.com/aircrack-ng/aircrack-ng/releases)
2. Run ```sudo pacman -U ./hashcatch-<ver>-1-any.pkg.tar.xz``` or ```sudo apt install ./hashcatch_<ver>_all.deb```
3. ```sudo hashcatch --setup```
4. Answer the prompts
5. And done!

#### Prerequisites
* aircrack-ng
* hashcat-utils
* hcxtools
* jq

#### Usage
```sudo hashcatch``` to start hashcatch

```hashcatch --help``` to print the help screen

* Hashcatch runs indefinitely until keyboard interrupt
* Handshakes captured will be stored in */usr/share/hashcatch/handshakes/*
* The captured WiFi network's BSSID and ESSID will be added to */usr/share/hashcatch/db*
* If you're targeting a wifi network, spend around 20 to 30 seconds within the wifi's range to ensure handshake capture
* [Experimental] If you are connected to the internet while capturing, the following data will also be added to the db file
  * latitude
  * longitude
  * signal radius
  * time of record
  * Note: Kudos to [Alexander Mylnikov](https://www.mylnikov.org) for the API he's running that returns the location details of a router's MAC address using public databases

#### The Configuration file
* The configuration file can be found in /etc/hashcatch/hashcatch.conf
* You can later edit the "interface" field to set the interface of your choice
* You can also add an "ignore" field to mention the WiFi networks you want hashcatch to ignore while running
* Refer the example given below to know about the format in which entries should be added to the configuration file
* Format ```option name=option1,option2,option3```
* No space in between option name, equal sign and options
* Example
```
interface=wlan0
ignore=Google Starbucks,AndroidAP
```

#### Features to be added
* More location features
* Automatic upload to websites to start cracking the handshake

#### Known Issues
1. [OSX] From issues raised by users, it seems airodump-ng is not working properly in OSX. Since it is a dependency for hashcatch, OSX users might not be able to run hashcatch.

Note: PMKID attack is not included in hashcatch because not all routers are vulnerable to the attack, hence checking for the attack increases the time taken in testing one AP. Pixiedust attack, and collecting information via WPS  while being effective, in a targetted attack, it also increases the time takes in testing one AP, which is not ideal for the mission of this tool, which is to be as fast as possible. Besides that, in my testing I found that there is one WPS enabled router for every 10 APs. Hence, the result provided by hashcatch will not be consistent and it can miss out on an oppurtunity to capture an extra handshake. So, as of now, hashcat will continue working with the conventional deauth and capture method.

PS: Even though I was working on hashcatch few days before [@evilsocket](https://twitter.com/evilsocket) posted about his [pwnagotchi](https://twitter.com/pwnagotchi), his work has definitely been an inspiration for this project!
