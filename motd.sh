let upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)" 
let secs=$((${upSeconds}%60)) 
let mins=$((${upSeconds}/60%60)) 
let hours=$((${upSeconds}/3600%24)) 
let days=$((${upSeconds}/86400)) 
UPTIME=`printf "%d days, %02dh%02dm%02ds" "$days" "$hours" "$mins" "$secs"`

read one five fifteen rest < /proc/loadavg
 
echo "$(tput setaf 2)
   .~~.   .~~.    `date +"%A, %e %B %Y, %r"`
  '. \ ' ' / .'   `uname -srmo`$(tput setaf 1)
   .~ .~~~..~.
  : .~.'~'.~. :   Uptime.............: ${UPTIME}
 ~ (   ) (   ) ~  Memory.............: `cat /proc/meminfo | grep MemFree | awk {'print $2'}`kB (Free) / `cat /proc/meminfo | grep MemTotal | awk {'print $2'}`kB (Total)
( : '~'.~.'~' : ) Load Averages......: ${one}, ${five}, ${fifteen} (1, 5, 15 min)
 ~ .~ (   ) ~. ~  Running Processes..: `ps ax | wc -l | tr -d " "`
  (  : '~' :  )   IP Addresses.......: `ip address list | grep "inet " | grep -v 127.0.0 | cut -d " " -f 6 | cut -d "/" -f 1`
   '~ .~~~. ~'    Weather............: `curl -s "http://rss.accuweather.com/rss/liveweather_rss.asp?metric=1&locCode=EUR|NL|NL005|GRONINGEN" | sed -n '/Currently:/ s/.*: \(.*\): \([0-9]*\)\([CF]\).*/\2Â°\3, \1/p'`
       '~'
	$(tput sgr0)"
#!/bin/bash

###########################################################################################################################################	
### BEGINNING OF USER CONFIGURABLE PARAMETERS
###########################################################################################################################################

    DOMO_IP="127.0.0.1"      																	# Domoticz IP
    DOMO_PORT="8080"         																	# Domoticz port
	
### Retrieve current and updated Domoticz version number
	DOMO_JSON_CURRENT=`curl -s -X GET "http://$DOMO_IP:$DOMO_PORT/json.htm?type=command&param=getversion"`
	DOMO_CHANNEL=$(echo $DOMO_JSON_CURRENT |grep -Po '(?<=channel=)[^&]*')
	DOMO_CURRENT_VERSION=$(echo $DOMO_JSON_CURRENT | grep -Po '(?<="version" : "4.)[^"]*')	
	DOMO_JSON_NEW=`curl -s -i -H "Accept: application/json" "http://$DOMO_IP:$DOMO_PORT/json.htm?type=command&param=checkforupdate&forced=true" | grep "Revision" `	
	DOMO_NEW_VERSION=$(echo $DOMO_JSON_NEW | grep -Po '(?<="Revision" : )[^,]*')	
	DOMO_CHANNEL=$(echo $DOMO_JSON_CURRENT | grep -Po '(?<=channel=)[^&]*')	

############################################################################################################################################
### END OF USER CONFIGURABLE PARAMETERS
############################################################################################################################################



	sudo apt-get update > /dev/null 2>&1

	repo=`sudo apt-get upgrade -d -y | grep 'upgraded,' | awk {'print $1'}`
		echo $repo > /mnt/storage/logging/repo_updates/repo_updates.txt

	rpi=`sudo apt-get install rpi-update -d -y | grep 'upgraded,' | awk {'print $1'}`
		echo $rpi > /mnt/storage/logging/repo_updates/rpi_updates.txt

	if [[ $(sudo JUST_CHECK=1 rpi-update | grep '*** Your firmware') = *Your* ]]; then
		echo "0" > /mnt/storage/logging/repo_updates/firmware_updates.txt 
	else
		echo "1" > /mnt/storage/logging/repo_updates/firmware_updates.txt
	fi

##	pihole=`sudo pihole -v`
##		echo $pihole > /mnt/storage/logging/repo_updates/pihole_updates.txt
##
############################################################################################################################################

	lowercase(){
    echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
	}

	OS=`lowercase \`uname -s\``
	MACH=`uname -m`
	if [ ${MACH} = "armv6l" ]
	then
	MACH="armv7l"
	fi
		
### Domoticz Update Check
	if [ $DOMO_CURRENT_VERSION = $DOMO_NEW_VERSION ] ; then
	echo 0 > /mnt/storage/logging/domo_updates/domo_updates.txt
	echo " " > /mnt/storage/logging/domo_updates/domo_update_from.txt
	echo " " > /mnt/storage/logging/domo_updates/domo_update_to.txt		
	fi	
	
	if  [ $DOMO_CURRENT_VERSION != $DOMO_NEW_VERSION ] ; then		
	echo 1 > /mnt/storage/logging/domo_updates/domo_updates.txt
	echo "- From: $DOMO_CURRENT_VERSION" > /mnt/storage/logging/domo_updates/domo_update_from.txt
	echo " To: $DOMO_NEW_VERSION" > /mnt/storage/logging/domo_updates/domo_update_to.txt		
	fi