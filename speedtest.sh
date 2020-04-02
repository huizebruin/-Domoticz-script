#!/bin/bash

#setup
host=192.168.178.234
port=8080
user=wobbe
pass=molenweg55
#idx for download, upload and ping
idxdl=11361
idxul=11362
idxpng=11360
idxbb=11363

# speedtest server number
# serverst=xxxx

# no need to edit
# speedtest-cli --simple --server $serverst > outst.txt
speedtest-cli --simple > speedtest.txt

#version that does not write a tempfile to disk
speedtest=$(speedtest-cli --simple)
png=$(echo "$speedtest" | sed -ne 's/^Ping: \([0-9]*\.[0-9]*\).*/\1/p')
download=$(echo "$speedtest" | sed -ne 's/^Download: \([0-9]*\.[0-9]*\).*/\1/p')
upload=$(echo "$speedtest" | sed -ne 's/^Upload: \([0-9]*\.[0-9]*\).*/\1/p')
# output if you run it manually
echo "Download = $download Mbps"
echo "Upload =  $upload Mbps"
echo "Ping =  $png ms"

# Updating download, upload and ping ..
wget -q --delete-after "http://$host/json.htm?type=command&param=udevice&idx=$idxdl&svalue=$download" >/dev/null 2>&1
wget -q --delete-after "http://$host/json.htm?type=command&param=udevice&idx=$idxul&svalue=$upload" >/dev/null 2>&1
wget -q --delete-after "http://$host/json.htm?type=command&param=udevice&idx=$idxpng&svalue=$png" >/dev/null 2>&1

# Reset Broadband switch
wget -q --delete-after "http://$host/json.htm?type=command&param=udevice&idx=$idxbb&svalue=0" >/dev/null 2>&1

# Domoticz logging
wget -q --delete-after "http://$host/json.htm?type=addlogmessage&message=speedtest.net-logging" >/dev/null 2>&1

exit 0