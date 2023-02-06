#!/bin/bash
## This script is used to update tast-files due to changes within the cros_sdk. 
## Running this script will reach into the cros_sdk, copy the designated tast files
## and place them in this directory. 

cros_sdk=/home/oem/PNP_June7/chromite/bin/cros_sdk
tastPath=/home/oem/chromiumos/src/platform/tast-tests/local_tests
crosRoot=/root/mtl_grab
autoGrab=/home/oem/Desktop/tast_files/mtl_grab
pull="${1:-pull}"
fileArray=( "mtl_lvp.go" "mtl_wall.go" "mtl_plt.go" "mtl_plt2.go" "mtl_gaia1.go" "mtl_gaia2.go" )

# check for mtl directory in cros_sdk /root, else create it
checkRoot(){
	if [[ ! -d "/home/oem/PNP_June7/chroot/${crosRoot}" ]]; then
		sudo mkdir "/home/oem/PNP_June7/chroot/${crosRoot}"
		echo "${crosRoot} directory created"
	else
		echo "${crosRoot} directory found"
		sleep 1s
	fi
}

checkRoot

if [[ "$pull" == "pull" ]]; then

$cros_sdk << EOF
	## LVP Tast File
	cd "${tastPath}"/filemanager
	sudo cp mtl_lvp.go "${crosRoot}"

	## IDO/S0ix Tast File
	cd "${tastPath}"/wallpaper
	sudo cp mtl_wall.go "${crosRoot}"

	## PLT Tast File
	cd "${tastPath}"/example
	sudo cp mtl_plt.go mtl_plt2.go "${crosRoot}"

	## GMeet Tast File
	cd "${tastPath}"/login
	sudo cp mtl_gaia1.go mtl_gaia2.go "${crosRoot}"

EOF

sudo mv ~/PNP_June7/chroot"${crosRoot}"/* "${autoGrab}"
sudo chown oem:oem "${autoGrab}"/mtl*

elif [[ "$1" == "push" ]]; then
	# If $2 is empty push all tast files
	if [[ -z "$2" ]]; then
		echo "Pushing all Tast files"
		sleep 1s
		echo "${fileArray[@]}"
		## Move files in array to cros_sdk intermediary directory
		sudo cp "${autoGrab}"/"${fileArray[@]}" ~/PNP_June7/chroot"${crosRoot}"
		sleep 1s
		## Move files into their respective directory
	$cros_sdk << EOF
			## LVP Tast File
			cd "${tastPath}"/filemanager
			sudo mv "${crosRoot}"/mtl_lvp.go . && echo "LVP copied to cros_sdk"

			## IDO/S0ix Tast File
			cd "${tastPath}"/wallpaper
			sudo mv "${crosRoot}"/mtl_wall.go . && echo "IDO/S0ix copied to cros_sdk"

			## PLT Tast File
			cd "${tastPath}"/example
			sudo mv "${crosRoot}"/mtl_plt.go mtl_plt2.go && echo "PLT copied to cros_sdk"

			## GMeet Tast File
			cd "${tastPath}"/login
			sudo mv "${crosRoot}"/mtl_gaia1.go mtl_gaia2.go && echo "GMEET copied to cros_sdk"

EOF
		
	fi

fi

exit
