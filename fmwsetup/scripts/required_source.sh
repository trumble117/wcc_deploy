#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# July 15th, 2015
#
# Test for the existence of all required source files and patches

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

declare -A INSTALLER_LIST
declare -A PATCH_LIST

INSTALLER_LIST[WebCenter_Content_Disk1]="ofm_wcc_generic_11.1.1.8.0_disk1_1of2.zip" 
INSTALLER_LIST[WebCenter_Content_Disk2]="ofm_wcc_generic_11.1.1.8.0_disk1_2of2.zip"
INSTALLER_LIST[Oracle_SOA_Suite_Disk1]="ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip"
INSTALLER_LIST[Oracle_SOA_Suite_Disk2]="ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip"
INSTALLER_LIST[Oracle_WebTier]="ofm_webtier_linux_11.1.1.9.0_64_disk1_1of1.zip"
INSTALLER_LIST[Oracle_RCU]="ofm_rcu_linux_11.1.1.8.0_64_disk1_1of1.zip"
INSTALLER_LIST[Oracle_WebLogic_Server]="wls1036_generic.jar"
INSTALLER_LIST[Java_JDK]="jdk-7u80-linux-x64.rpm"

PATCH_LIST[WebCenter_Content]="p21168615_111180_Generic.zip"
PATCH_LIST[Oracle_SOA_Suite]="p20900797_111170_Generic.zip"
PATCH_LIST[Oracle_WebLogic_Server]="p20780171_1036_Generic.zip"
PATCH_LIST[Oracle_OPatch]="p6880880_111000_Linux-x86-64.zip"

echo ">> Checking stage directories for required installers and patches."
echo ">> ... Please wait ..."
echo
sleep 1

all_ok=true

# Check all installers
for product in "${!INSTALLER_LIST[@]}"; do
	if [[ ! -e $STAGE_DIR/${INSTALLER_LIST[$product]} ]]; then
		echo "!! Missing Installer: $product - ${INSTALLER_LIST[$product]}"
		all_ok=false
	fi
done

# Check all patches
for patch in "${!PATCH_LIST[@]}"; do
	if [[ ! -e $STAGE_DIR/PATCHES/${PATCH_LIST[$patch]} ]]; then
		echo "!! Missing Patch: $patch - ${PATCH_LIST[$patch]}"
		all_ok=false
	fi
done

echo

# If failures occurred, sent failure signal back to caller
[[ "$all_ok" = false ]] && echo ">>> Errors occurred. Terminating deployment." && exit 2

echo ">>> All resource file checks passed. Deployment may proceed."