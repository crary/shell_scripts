#! /bin/bash
# Captures BTmon output for specific set of time and runtime status output a specific time marker. 

i=0
time=181

if [[ ! -d /home/btmon ]]; then
	mkdir /home/btmon
fi

echo "Initial runtime status ..." > /home/btmon/watch_log
cat /sys/bus/usb/devices/3-10/power/runtime_status >> /home/btmon/watch_log.txt
btmon > /home/btmon/btmon_initial.txt &
bt_ps1=$(echo $!)

while [ $i -lt $time ]; do
	sleep 1
		if [ $i == 60 ]; then
		echo "1 minute mark" >> /home/btmon/watch_log.txt && cat /sys/bus/usb/devices/3-10/power/runtime_status >> /home/btmon/watch_log.txt
		kill -9 $bt_ps1
		btmon > /home/btmon/btmon_1min.txt &
		bt_ps2=$(echo $!)
		fi
		
		if [ $i == 120 ];then
		echo "2 minute mark" >> /home/btmon/watch_log.txt && cat /sys/bus/usb/devices/3-10/power/runtime_status >> /home/btmon/watch_log.txt
		kill -9 $bt_ps2
		btmon > /home/btmon/btmon_2min.txt &
		bt_ps3=$(echo $!)
		fi
		
		if [ $i == 180 ];then
		echo "3 minute mark" >> /home/btmon/watch_log.txt && cat /sys/bus/usb/devices/3-10/power/runtime_status >> /home/btmon/watch_log.txt
		kill -9 $bt_ps3
		fi
	
	
	i=$(( $i+1 ))
done

cd /home
tar -czf btmon_logs.tar.gz ./btmon/*
