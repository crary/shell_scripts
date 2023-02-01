#!/bin/bash
## This script is used to update tast-files due to changes within the cros_sdk. 
## Running this script will reach into the cros_sdk, copy the designated tast files
## and place them in this directory. 

cros_sdk=/home/oem/PNP_June7/chromite/bin/cros_sdk
tastPath=/home/oem/chromiumos/src/platform/tast-tests/local_tests
crosRoot=/root/new_grab
autoGrab=/home/oem/Desktop/tast_files/auto_grab
pull="${1:-pull}"

if [[ "$pull" == "pull" ]]; then
$cros_sdk << EOF
## LVP Tast File
cd "${tastPath}"/filemanager
sudo cp quick_lvp.go quick_lvplay.go "${crosRoot}"

## IDO/S0ix Tast File
cd "${tastPath}"/wallpaper
sudo cp quick_wallplay.go "${crosRoot}"

## PLT Tast File
cd "${tastPath}"/example
sudo cp quick_pltplay.go quick_pltplay2.go "${crosRoot}"

## GMeet Tast File
cd "${tastPath}"/login
sudo cp quick_gaia.go quick_gaiaplay.go "${crosRoot}"

## ADB Connect Tast File
#cd "${tastPath}"/login
#sudo cp quick_adb.go quick_adb2.go "${crosRoot}"
EOF

fi

sudo mv ~/PNP_June7/chroot"${crosRoot}"/* "${autoGrab}"
sudo chown oem:oem "${autoGrab}"/quick*

exit
