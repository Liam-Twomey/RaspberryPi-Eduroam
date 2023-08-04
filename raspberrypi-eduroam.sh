#!/bin/bash
#By Liam Twomey, based on the UCSC help article https://inrg.soe.ucsc.edu/howto-connect-raspberry-to-eduroam/

PrintUsage(){
	printf "Usage:
	-i: Accepts user's Kerberos password as argument, and adds an 'eduroam' shortcut for this command to ~/.bashrc and ~/.zshrc if they exist.
	-h: Prints this usage info. Refer to https://inrg.soe.ucsc.edu/howto-connect-raspberry-to-eduroam/ for more info 
	All other parameters accepted as bash <read> parameters.
	This program changes:
		/etc/network/interfaces,
		/etc/wpa_supplicant/wpa_supplicant.conf"
	exit 1
}
IfdownShutdown(){
	sudo ifdown wlan0
	sudo ifdown eth0
	sudo killall wpa-supplicant
}
EditFiles(){
	#Shutdown hardware and processes
	IfdownShutdown
	# Update wifi config to check wpa_supplicant.conf for config settings
	sudo echo -e "# Changes made by Raspberry Pi Eduroam Configuration script. 
	allow-hotplug wlan0
	iface wlan0 inet manual
	\twpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
	iface wlan0 inet dhcp" >> $interfacefile 

	# Update settings in wpa_supplicant.conf
	sudo echo -e "# Changes made by the Raspberry Pi Eduroam Configuration script.  
	ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
	update_config=1
	country=$input_loc
	network={
	\tssid=\"eduroam\"
	\teap=PEAP
	\tkey_mgmt=WPA-EAP
	\tphase2=\"auth=MSCHAPV2\"
	\tidentity=\"$input_username\"
	\tpassword=\"$input_passwd\"
	}" >> $conffile && 
	printf "\033[32mSettings changed.\033[0m\nTo view changes, visit $conffile. Automated changes were also made to $interfacefile. Run script with the -i flag to verify successful connection.\n" 
}

InitEduroam(){
	IfdownShutdowni
	initCmd='alias eduroam="sudo wpa_supplicant -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf &"'
	rcFiles=('$HOME/.bashrc' '$HOME/.zshrc')
	#Add 'eduroam' command to existing shell rc files.
	for rcFile in $rcFiles; do	
		if [ -f "$rcfile"]; then #&& [! grep "$initCmd" "$rcFile"]; then
			echo "$initCmd" >> "$rcFile"
		fi
	done
	sudo wpa_supplicant -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf &
}

# Process flags
while getopts 'ih' flag; do
  case "${flag}" in
    i) InitEduroam; exit;; 
    h) PrintUsage; exit;;
    \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
    :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
    *  ) echo "Unimplemented option: -$option" >&2; exit 1;;
  esac
done

#Source Files
interfacefile="/etc/network/interfaces"
conffile="/etc/wpa_supplicant/wpa_supplicant.conf"
# Obtain user info
read -p "Kerberos/Eduroam username:" input_username
read -p "Kerberos/Eduroam password:" input_passwd
read -p "Network Location (ISO country code):" input_loc
echo -e "Entries:\n\tUsername:\t$input_username \n\tPassword:\t${#input_passwd} characters\n\tRegion:\t $input_loc\n\033[93mDo you want to proceed? (y/n):\033[0m"; read confirm

case $confirm in
	[nN]* ) echo -e "\033[31mCancelling...\033[0m"; exit 1;;
	[yY]* ) EditFiles;;
	* ) echo "Please answer Y or N."
esac
