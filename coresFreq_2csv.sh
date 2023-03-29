#!/bin/bash

runTime=300 #In seconds
textfile="cpu_freq.txt"


#/sys/devices/system/cpu/cpu[#]/cpufreq/scaling_cur_freq
#/sys/cless/drm/card0/gt_cur_freq_mhz

## Capture CPU Freq. output from all cores
while [[ $runTime -gt 0 ]]; do
	cat /sys/devices/system/cpu/cpu{0..11}/cpufreq/scaling_cur_freq) | paste -sd ',' >> tmp
	sleep 1
	runTime=$(( $runTime - 1))
done

## Number lines to match seconds
nl -w2 -s', ' tmp >> "${textfile}"

## Remove tmp file
rm tmp