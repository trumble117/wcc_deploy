#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Configure all system prerequisites prior to software installation and configuration

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

echo "> Deleting $FMW_HOME"
sudo rm -rf $FMW_HOME

echo "> Deleting $DOMAIN_BASE"
sudo rm -rf $DOMAIN_BASE

echo "> Deleting Inventory"
sudo rm -rf /u01/app/oraInventory
sudo rm -rf /etc/oraInst.loc