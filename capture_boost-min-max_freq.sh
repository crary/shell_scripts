#!/bin/bash

outputFile=$1

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