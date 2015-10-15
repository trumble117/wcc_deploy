#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# April 3, 2015
#
# Unzip binary installers
#
# CHANGELOG
# 07/15/2015 - Updated software list for July 2015

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

/bin/chmod a+x $STAGE_DIR/${INSTALLER_LIST[Oracle_WebLogic_Server]}

echo "> Unzipping installer binaries. This can take a while..."
## Stage install files
cd $STAGE_DIR
# WebCenter Content
[[ ! -d WCC ]] && mkdir WCC && echo "> Successfully created WCC directory"
if [[ "$(ls -A WCC)" ]]; then
	echo ">> WCC directory is nonempty. Assuming unzip has already occurred."
else
	echo ">> Unzip WCC binaries"
	/usr/bin/unzip -qo ${INSTALLER_LIST[WebCenter_Content_Disk1]} -d WCC
	/usr/bin/unzip -qo ${INSTALLER_LIST[WebCenter_Content_Disk2]} -d WCC
fi

# SOA Suite
[[ ! -d SOA ]] && mkdir SOA && echo "> Successfully created SOA directory"
if [[ "$(ls -A SOA)" ]]; then
	echo ">> SOA directory is nonempty. Assuming unzip has already occurred."
else
	echo ">> Unzip SOA binaries"
	/usr/bin/unzip -qo ${INSTALLER_LIST[Oracle_SOA_Suite_Disk1]} -d SOA
	/usr/bin/unzip -qo ${INSTALLER_LIST[Oracle_SOA_Suite_Disk2]} -d SOA
fi

# Web Tier
[[ ! -d WT ]] && mkdir WT && echo "> Successfully created WT directory"
if [[ "$(ls -A WT)" ]]; then
	echo ">> WT directory is nonempty. Assuming unzip has already occurred."
else
	echo ">> Unzip WT binaries"
	/usr/bin/unzip -qo ${INSTALLER_LIST[Oracle_WebTier]} -d WT
fi

# RCU 11.1.1.8
[[ ! -d RCU_11118 ]] && mkdir RCU_11118 && echo "> Successfully created RCU directory"
if [[ "$(ls -A RCU_11118)" ]]; then
	echo ">> RCU directory is nonempty. Assuming unzip has already occurred."
else
	echo ">> Unzip RCU"
	/usr/bin/unzip -qo ${INSTALLER_LIST[Oracle_RCU]} -d RCU_11118
fi

# Create central inventory
sudo ./WCC/Disk1/stage/Response/createCentralInventory.sh /u01/app/oraInventory oinstall