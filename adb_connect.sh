#!/bin/bash
# Script is used as part of Performance Automation for ADB connection to DUT
# IP address is needed in $1 position

## Delay script 
sleep 80

## Use ping to Wait for AMR connection to DUT
while  ! ping -c 1 -n -w 1 $1 &> /dev/null;
do
	sleep 10
	echo "Waiting for restablished connection to DUT"
done


## Wait for ADB Connection Signal from DUT
sshpass -p test0000 ssh -tt root@$1 << EOF
until [ -f /tmp/connect_adb.txt ]; 
do
	sleep 1
done
echo "ADB ready to connect"
rm /tmp/connect_adb.txt
exit 
EOF


## Connect to ADB 
adb kill-server 
echo "ADB server killed" 
adb connect $1 
