#!/bin/sh
## eth0 settings
NAMEOFAPP="eth0"
WHATITDOES="This will set a static IP address for the interface."

## Current User
CURRENTUSER="$(whoami)"

## Dependencies Check
sudo bash /etc/piadvanced/dependencies/dep-whiptail.sh

## Variables
source /etc/piadvanced/install/firewall.conf
source /etc/piadvanced/install/variables.conf
source /etc/piadvanced/install/userchange.conf

{ if 
(whiptail --title "$NAMEOFAPP" --yes-button "Skip" --no-button "Proceed" --yesno "Do you want to setup $NAMEOFAPP? $WHATITDOES" 10 80) 
then
echo "$CURRENTUSER Declined $NAMEOFAPP" | sudo tee --append /etc/piadvanced/install/installationlog.txt
echo ""$NAMEOFAPP"install=no" | sudo tee --append /etc/piadvanced/install/variables.conf
else
echo "$CURRENTUSER Accepted $NAMEOFAPP" | sudo tee --append /etc/piadvanced/install/installationlog.txt
echo ""$NAMEOFAPP"install=yes" | sudo tee --append /etc/piadvanced/install/variables.conf

## Below here is the magic.
OLDETH_IP=`ip addr show eth0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1`
OLDETH_GATEWAY=`ip route show 0.0.0.0/0 dev eth0 | cut -d\  -f3`
NEWETH_IP=$(whiptail --inputbox "Please enter desired IP for eth0" 10 80 "$OLDETH_IP" 3>&1 1>&2 2>&3)
sudo cp /etc/dhcpcd.conf /etc/piadvanced/backups/dhcpcd.conf
sudo sed -i '/#eth0/d' /etc/dhcpcd.conf
sudo sed -i '/interface eth0/d' /etc/dhcpcd.conf
sudo sed -i '/static ip_address=$OLDETH_IP/d' /etc/dhcpcd.conf
sudo sed -i '/static routers=$OLDETH_GATEWAY/d' /etc/dhcpcd.conf
sudo sed -i '/static domain_name_servers=$OLDETH_GATEWAY/d' /etc/dhcpcd.conf
sudo echo "NEWETH_IP=$NEWETH_IP" | sudo tee --append /etc/piadvanced/install/variables.conf
sudo echo "" | sudo tee --append /etc/dhcpcd.conf
sudo echo "#eth0" | sudo tee --append /etc/dhcpcd.conf
sudo echo "interface eth0" | sudo tee --append /etc/dhcpcd.conf
sudo echo "static ip_address=$NEWETH_IP" | sudo tee --append /etc/dhcpcd.conf
sudo echo "static routers=$OLDETH_GATEWAY" | sudo tee --append /etc/dhcpcd.conf
sudo echo "static domain_name_servers=$OLDETH_GATEWAY" | sudo tee --append /etc/dhcpcd.conf
sudo ifconfig eth0 $NEWETH_IP

## End of install
fi }

## Unset Temporary Variables
unset NAMEOFAPP
unset CURRENTUSER
unset WHATITDOES

## Module Comments
