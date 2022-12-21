#!/bin/bash

#Set global variables for all functions
function startup()
{
	mount -o remount,rw,exec /home/
	alias a_stopScript='./a_stopScript/*.sh'
	pwd=$(pwd)
	bright_default=35.000000
	usb_path="/media/removable/data_dc/"
	
	#automatically expands \n using echo
	shopt -s xpg_echo
	
	helpmsg="
	function list:
		Settings
			rootfs 		-- Remove root verification
			check_pc10 	-- Check Package State PC10 intrementation
			check_s0ix	-- Check s0ix incrementation
			check_s02	-- Check s0i2/3 residencies for incrementation
			set_epp		-- Set epp values
			get_epp		-- Get epp values
			state_s0ix	-- Put DUT into S0ix state
			dut_BKC		-- Pull DUT OS/CB/EC w/optional file export
			set_Bright	-- Set system brightness
			get_Bright	-- Get system brightness
		
		Stop Script
			gen_stpScpt -- Execute generic stop script
			mod_Scpt 	-- Modify and run different stop script options
			stp_bt		-- Run stop script without bluetooth
			stp_pwrd	-- run stop script without powerd
			notty		-- run stop script without ttyS0			
		
		Performance KPI
			s0ix_resume	-- Run S0ix resume time 3x w/averages
			
		Athena
			ath_install -- Install Athena Tool
			ath_uninstl -- Uninstall Athena Tool
			ath_RESP	-- Run Athena Responsiveness Test
			ath_PABL	-- Run Athena Battery Power Test

		SocWatch
			soc_run		-- Run SocWatch with order options: 
						   iterations, wait, record, file name
			soc_instll	-- Extract driverless SocWatch to DUT
			soc_xtrct	-- Copy most recent socwatch tar file to USB
			
			
		"
}
startup

#Show user output help file
helper(){
	echo "$helpmsg"
}

#Remove rootfs verification
function rootfs(){
	read -p "Remove root verification?" -n 1 -r
    if [[  $REPLY =~ ^[Yy]$ ]]; then
	sleep 3
       /usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification --force && reboot
	fi
}

#Set epp values
set_epp(){
	mount -r remount,rw, exec /home/
	. /home/set_Script/epp/set_epp_v2.sh $1
#	|  awk '{print int($1 * 255 / 100 + 0.5)}'
}

#Get epp values
get_epp(){
	. /home/set_Script/epp/get_epp_v2.sh
#	|  awk '{print int($1 * 255 / 100 + 0.5)}'
}

# Check PC10
check_pc10(){
	cat /sys/kernel/debug/pmc_core/package_cstate_show
	echo ""
	
	pc10_1=$(cat /sys/kernel/debug/pmc_core/package_cstate_show | tail -n 1 | egrep -o [0-9]+$)
	sleep 2
	pc10_2=$(cat /sys/kernel/debug/pmc_core/package_cstate_show | tail -n 1 | egrep -o [0-9]+$)
		
		if [[ $pc10_1 -le $pc10_2 ]]; then
		echo "PC10 is incrementing"
			else
		echo "PC10 DID NOT incriment"
		fi
}

#S0ix incrementation check
check_s0ix(){
	cat /sys/kernel/debug/pmc_core/slp_s0_residency_usec
	var1=$(cat /sys/kernel/debug/pmc_core/slp_s0_residency_usec)
	suspend_stress_test -c 1 --suspend_max 3
	var2=$(cat /sys/kernel/debug/pmc_core/slp_s0_residency_usec)
	sleep 2
	
	echo "$var2"
		if [[ $var1 < $var2 ]]; then
		echo "S0ix is incrementing"
			else
		echo "S0ix DID NOT incriment"
		fi
}

#Check S0i2/S0i3 substate residencies
check_s02(){
	sleep 2
	cat /sys/kernel/debug/pmc_core/substate_residencies
	sleep 2
	cat /sys/kernel/debug/pmc_core/substate_residencies
}

# Put DUT into S0ix state
state_s0ix(){
	echo freeze > /sys/power/state
}

#Run S0ix resume time
s0ix_resume(){
	i=0
	while [ $i -lt 3 ]; do
	
	suspend_stress_test -c 3 --suspend_max 10 --suspend_min 10 --wake_max 5 --wake_min 5
	s0ix_var1=$(dmesg | grep "PM: resume of devices complete" | egrep -o "\s[0-9]{3}.[0-9]{3}" | xargs | sed -e 's/\ /+/g' | bc)
	
	ix_r1=$(echo "scale=3 ; s0ix_var1 / 3" | bc)
	echo "Resume time run $i total is $ix_r1"
	i=$(( $i+1 ))
	done
}

#Pull OS, coreboot and EC information from DUT with optional export to text file
dut_BKC(){
	output_file="/home/dut_os-cb-ec_$(date +%Y-%m-%d).txt"
	
	cat /etc/os-release 
	crossystem | grep fwid 
	ectool version 
	
	read -p "Save DUT BKC to file? " -n 1 -r
    if [[  $REPLY =~ ^[Yy]$ ]]; then	
		cat /etc/os-release > $output_file
		crossystem | grep fwid >> $output_file
		ectool version >> $output_file
	fi
	echo "\n"
}

#Set system brightness
set_Bright(){
	backlight_tool --set_brightness_percent="$1"
	
	if [ $? = "0" ]; then
	echo "Brightness set to $(get_Bright)"
	fi
}

#Get system brightness
get_Bright(){
	backlight_tool --get_brightness_percent
}

# Execute Generic Stop Script
gen_stpScpt(){
	. /home/set_Script/stopScript/generic/generic_stop-script.sh
	check_s02
}

# Run modified stop script options to allow or disallow specific commands
mod_Scpt(){
	read -p "Choose mod [ BT, pwrd, notty ]" modss
	case $modss in
		BT)	$(stp_bt) ;;
		pwrd) $(stp_pwrd)	;;
		notty) $(notty)	;;	
		*) echo "Valid mod not selected"
	esac
}

# Run stop script without Blue tooth
stp_bt(){
	if [ ! -f /home/set_Script/StopScript/generic/generic_stop_script_BT0ff ]; then
		cp /home/set_Script/StopScript/generic/generic_stop-script.sh /home/set_Script/StopScript/generic/generic_stop_script_BT0ff.sh
		sed -E -i '11s/^/#/' /home/set_Script/StopScript/generic/generic/generic_stop_script_BT0ff.sh
		. /home/set_Script/StopScript/generic/generic_stop_script_BT0ff.sh
	else
		. /home/set_Script/StopScript/generic/generic_stop_script_BT0ff.sh
	fi
}  	
# Run stop script without powerd
stp_pwrd(){
	if [ ! -f /home/set_Script/StopScript/generic/generic_stop_script_pwrdOFF ]; then
		cp /home/set_Script/StopScript/generic_stop-script.sh /home/set_Script/StopScript/generic/generic_stop_script_pwrdOFF.sh
		sed -E -i '9s/^/#/' /home/set_Script/StopScript/generic/generic_stop_script_pwrdOFF.sh
		. /home/set_Script/StopScript/generic/generic_stop_script_pwrdOFF.sh
	else
		. /home/set_Script/StopScript/generic/generic_stop_script_pwrdOFF.sh
	fi
}

# Run stop script without ttyS0
notty(){
	if [ ! -f /home/set_Script/StopScript/generic/generic_stop_script_notty ]; then
		cp /home/set_Script/StopScript/generic/generic_stop-script.sh /home/set_Script/StopScript/generic/generic_stop_script_notty.sh
		sed -E -i '15s/^/#/' /home/set_Script/StopScript/generic/generic_stop_script_notty.sh
		. /home/set_Script/StopScript/generic/generic_stop_script_notty.sh
	else
		. /home/set_Script/StopScript/generic/generic_stop_script_notty.sh
	fi
}

# Install Athena
ath_install(){
	if [ ! -d /home/chronos/user/Downloads/v3* ]; then
		cd /home/set_Script/
		cp -r ./athena/v3.3."$1" /home/chronos/user/Downloads
		chmod 777 /home/chronos/user/Downloads/v3.3."$1"/IATBrowsing/chrome_iatv3_installer.sh chrome_iatv3_setup.sh input-batterylife-chrome.json input-responsiveness-chrome.json
		
		# pipe y to pass yes to the command when prompted
		y | bash /home/chronos/user/Downloads/v3.3."$1"/IATBrowsing/chrome_iatv3_setup.sh
	else
		if [ ! -f /home/chronos/user/Downloads/v3.3."$1"/setup.log ]; then
			touch /home/chronos/user/Downloads/v3.3."$1"/setup.log
			echo "1" > /home/chronos/user/Downloads/v3.3."$1"/setup.log
			bash /home/chronos/user/Downloads/v3.3."$1"/IATBrowsing/chrome_iatv3_setup.sh | tee /home/chronos/user/Downloads/v3.3."$1"/iatv3_setup_output.txt
		else
			cd /home/chronos/user/Downloads/v3.3."$1"/IATBrowsing
			bash chrome_iatv3_installer.sh
		fi
	fi
}

# Uninstall Athena Tool
ath_uninstl(){
	if [ -z "$1" ]; then
		echo "Please Enter Version Number"
	else
		rm -r /home/chronos/user/Downloads/v3.3."$1"
		rm -r /usr/local/bin/IATv3
		echo "Athena Tool v3.3.$1 removed"
	fi
}

# Run Athena tool for responsiveness, set iterations with $1 argument 
ath_RESP(){
	cd /usr/local/bin/IATv3
	sed -E -i '17s/[0-9]+/'$1'/' /usr/local/bin/IATv3/input-responsiveness-chrome.json
	cat input-responsiveness-chrome.json | head -n 17
	./IATBrowsingChrome wfinput input-responsiveness-chrome.json
}

# Run Athena tool for battery power test, set iterations with $1 argument 
ath_PABL(){
	cd /usr/local/bin/IATv3
	sed -E -i '17s/[0-9]+/'$1'/' /usr/local/bin/IATv3/input-batterylife-chrome.json
	./IATBrowsingChrome wfinput input-batterylife-chrome.json
}

# Run socwatch with options: iterations, wait, record, output file name
soc_run(){
	cd /home/set_Script/sh_scpts
	./soc_loop.sh $1 $2 $3 $4
}

# Extract driverless SocWatch to DUT
soc_instll(){
	if [[ ! -d /home/socWatch ]]; then
		mkdir /home/socWatch
	fi
	tar -xvf /home/set_Script/socwatch/*.tar.gz -C /home/
}

# Copy most recent socwatch tar file to USB
soc_xtrct(){
	soc_tar=$( ls -1t /home/socWatch | head -1 )
	cp -r $soc_tar $usb_path/socWatch_Data
}
