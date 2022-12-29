#!/bin/sh

#This script is used to set, change and monitor brightness level.
#Set iterations and specifiy sample rate in seconds.

# -z option will test if the expansion of "$2" is a null string or not, taking user input to name output file.
if [ -z "$2" ]; then
	log="brightness_log.txt"
else
	log="$2".txt
fi

i="$1"
time=$(date +%H%M)
seconds=300
bright_level=60.500000


echo "start time is $time" >> $log
while [ "$i" -gt 0 ]; do
	bright=$(backlight_tool --get_brightness_percent)
	sleep $seconds 
	backlight_tool --get_brightness_percent >> $log
	i=$(( $i-1 ))


# Change brightness to set value if value is not correct
		if [[ "$bright" != "$bright_level" ]]; then
			time=$(date +%H%M)
			backlight_tool --set_brightness_percent="$bright_level"
			echo "Brightness changed at "$time >> $log
		fi 
done
echo "Finished at $time" >> $log

#Calculate total runtime in minutes
run_Time=$( "$i" * "$seconds" | bc)
final_time=$( "$run_Time" / 60 | bc)
echo "Total runtime was $final_time minutes" >> $log
exit





