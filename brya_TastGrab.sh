#!/bin/bash
## This script is used to update tast-files due to changes within the cros_sdk. 
## Running this script will reach into the cros_sdk, copy the designated tast files
## and place them in a designated directory. 

cros_sdk=/home/oem/PNP_June7/chromite/bin/cros_sdk
tastPath=/home/oem/chromiumos/src/platform/tast-tests/local_tests
crosRoot=/root/brya_grab
bryaGrab=/home/oem/Desktop/tast_files/brya_grab

# Copy Brya Tast files to swap directory in cros_sdk root
$cros_sdk << EOF
## Brya LVP Tast File
cd "${tastPath}"/filemanager
sudo cp brya_lvplay.go "${crosRoot}"

## Brya IDO/S0ix Tast File
cd "${tastPath}"/wallpaper
sudo cp brya_wallplay.go "${crosRoot}"

## Brya PLT Tast File
cd "${tastPath}"/example
sudo cp brya_pltplay.go "${crosRoot}"

## Brya GMeet Tast File
cd "${tastPath}"/login
sudo cp brya_gaia.go brya_gaiaplay.go "${crosRoot}"
EOF

# Move files to direcrory on Linux Host and change ownership
sudo mv ~/PNP_June7/chroot"${crosRoot}"/* "${bryaGrab}"
sudo chown oem:oem "${bryaGrab}"/brya*
#exit
