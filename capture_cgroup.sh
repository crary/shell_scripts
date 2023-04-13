#!/bin/bash

outputFile=$1

## Capture cgroup settings ##
cgrpChrome=$(cat /sys/fs/cgroup/cpuset/chrome/cpus)
cgrpUrgent=$(cat /sys/fs/cgroup/cpuset/chrome/urgent/cpus)
cgrpUserSpace=$(cat /sys/fs/cgroup/cpuset/user_space/media/cpus)

echo "### cgroup settings ###" | tee -a "$outputFile"
echo "chrome/cpus: ${cgrpChrome}" | tee -a "$outputFile"
echo "urgent/cpus: ${cgrpUrgent}" | tee -a "$outputFile"
echo "user_space/cpus: ${cgrpUserSpace}" | tee -a "$outputFile"
printf '\n' >> "$outputFile"
printf '\n'
sleep 2




