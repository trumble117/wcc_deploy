#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Configure all system prerequisites prior to software installation and configuration

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

if [[ $MULTINODE == 0 ]]; then
	echo "> Deleting $FMW_HOME"
	sudo rm -rf $FMW_HOME
	
	echo "> Deleting $DOMAIN_BASE"
	sudo rm -rf $DOMAIN_BASE
fi

echo "> Deleting Inventory"
sudo rm -rf /u01/app/oraInventory
sudo rm -rf /etc/oraInst.loc

echo "> Reverting firewall"
sudo bash -c "iptables-restore < /etc/sysconfig/iptables-BAK"
sudo bash -c "iptables-save > /etc/sysconfig/iptables"