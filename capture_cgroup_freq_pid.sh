#!/bin/bash

dt=$(date '+%Y-%m-%d')
outputFile=${$1:="${dt}_setting_capture.txt"}

## Capture PSR ## 
psrCap=$(cat /proc/cmdline | grep -io 'psr=..')
echo "### PSR status capture ###" | tee -a "$outputFile"
"${psrCap}" >> "$outputFile"
printf '\n' >> "$outputFile"

## Capture cgroup settings ##
cgrpChrome=$(cat /sys/fs/cgroup/cpuset/chrome/cpus)
cgrpUrgent=$(cat /sys/fs/cgroup/cpuset/chrome/urgent/cpus)
cgrpUserSpace=$(cat /sys/fs/cgroup/cpuset/user_space/media/cpus)

cgrp(){
echo "### cgroup settings ###" | tee -a "$outputFile"
echo "chrome/cpus: ${cgrpChrome}" | tee -a "$outputFile"
echo "urgent/cpus: ${cgrpUrgent}" | tee -a "$outputFile"
echo "user_space/cpus: ${cgrpUserSpace}" | tee -a "$outputFile"
printf '\n' >> "$outputFile"
printf '\n'
sleep 2
}

## Capture Boost/Min/Max frequency ##
boostFreq=$(cat /sys/class/drm/card0/gt_boost_freq_mhz)
minFreq=$(cat /sys/class/drm/card0/gt_min_freq_mhz)
maxFreq=$(cat /sys/class/drm/card0/gt_max_freq_mhz)

echo "### Boost/Min/Max frequency settings ###" | tee -a "$outputFile"
echo "Boost Frequency: ${boostFreq}" | tee -a "$outputFile"
echo "Min Frequency: ${minFreq}" | tee -a "$outputFile"
echo "Max Frequency: ${maxFreq}" | tee -a "$outputFile"
printf '\n' >> "$outputFile"
sleep 2

### Capture service pid: Browser, GPU, GMEET-Tab ###


