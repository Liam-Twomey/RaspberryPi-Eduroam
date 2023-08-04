# RaspberryPi-Eduroam
Shell script to modify WPA config files on a raspberry pi to enable connections to Eduroam.

## Some background
- Eduroam is a system allowing access to wifi networks at different institutions via one set of credentials, used by many institutions including the University of California system.
- Raspberry Pi single-board computers cannot connect to Eduroam by default, due not to hardware but due to their WPA configurations.
- I wrote this shell script to automate a [process](https://inrg.soe.ucsc.edu/howto-connect-raspberry-to-eduroam/) outlined by UCSC i-NRG on getting a Raspberry Pi onto Eduroam.
- ___A note on security:___ This script uses the bash `read` command to avoid the username and password being recorded in the system's record of executed commands. That being said, please safeguard the root password to your Pi, as this enters the user's Kerberos ID and password into `/etc/wpa_supplicant/wpa_suppicant.conf` as plaintext. If this script is used please ensure that the Pi is not set to auto-login on boot, and that all users other than the one whose ID is used should exclusively access the Pi as a non-root user.
## Usage
__Cautions:__
- _I do not guarantee that this is foolproof.
- Please do not execute the shell script unless you understand the commands involved.
- The script does not check for redundancy (i.e. whether similar modifications have been made already to the config files). It _will_ repeat modifications if run twice, and I have no idea what that will do. Please check your config files (`/etc/network/interfaces` and `/etc/wpa_supplicant/wpa_suppicant.conf`) and be sure you understand what the script is doing before proceeding!_
That being said, this should work well on a Raspberry Pi with the default WPA configuration.
- Check `\etc\network\interfaces` for the following lines:
```bash
allow-hotplug wlan0
iface wlan0 inet manual
  wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
iface wlan0 inet dhcp
```
If any of these lines are present, __do not use this script__, follow the instructions in the article to make the only the necessary changes.

-Check `/etc/wpa_supplicant/wpa_suppicant.conf` for the following lines:
```bash
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US
network={
	ssid="eduroam"
	eap=PEAP
	key_mgmt=WPA-EAP
	phase2="auth=MSCHAPV2"
	identity="<Username@institution.edu>"
	password="<password>"
}
```
There may be other `network` blocks in your file, as long as none are named eduroam and none of the lines outside the `network` block are present, it should be safe to run.

- Download the script `raspberrypi-eduroam.sh` to any directory on the raspberry pi. Read the script and be sure you understand what it is doing. Please never execute shell scripts you do not understand fully!
- Open a terminal, `cd` to the directory containing the script, and `sudo chmod +x raspberrypi-eduroam.sh` to allow execution of the script
- use `./raspberrypi-eduroam.sh` to run the script. Use the `-h` flag for usage help.
- Enter the Kerberos ID, password, and country where the Eduroam network is located (this uses ISO codes, so United States would be `US`, France would be `FR`, etc.)
- When the script has completed, the script will print `Settings changed.`
-Run `./raspberrypi-eduroam.sh -i`to connect to Eduroam; this should output a line reading `Authentication successful`. If it does, then you're done; if not, please run with the `-I` flag to view the verbose output of the connection command, and refer to the troubleshooting guide in the [original article](https://inrg.soe.ucsc.edu/howto-connect-raspberry-to-eduroam/).
