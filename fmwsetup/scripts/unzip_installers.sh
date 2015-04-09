#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# April 3, 2015
#
# Unzip binary installers
#
# CHANGELOG

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

chmod a+x $STAGE_DIR/wls1036_generic.jar

echo "> Unzipping installer binaries. This can take a while..."
## Stage install files
cd $STAGE_DIR
# WebCenter Content
[[ ! -d WCC ]] && mkdir WCC && echo "> Successfully created WCC directory"
if [[ "$(ls -A WCC)" ]]; then
	echo ">> WCC directory is nonempty. Assuming unzip has already occurred."
else
	echo ">> Unzip WCC binaries"
	unzip -qo ofm_wcc_generic_11.1.1.8.0_disk1_1of2.zip -d WCC
	unzip -qo ofm_wcc_generic_11.1.1.8.0_disk1_2of2.zip -d WCC
fi

# SOA Suite
[[ ! -d SOA ]] && mkdir SOA && echo "> Successfully created SOA directory"
if [[ "$(ls -A SOA)" ]]; then
	echo ">> SOA directory is nonempty. Assuming unzip has already occurred."
else
	echo ">> Unzip SOA binaries"
	unzip -qo ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip -d SOA
	unzip -qo ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip -d SOA
fi

# Web Tier
[[ ! -d WT ]] && mkdir WT && echo "> Successfully created WT directory"
if [[ "$(ls -A WT)" ]]; then
	echo ">> WT directory is nonempty. Assuming unzip has already occurred."
else
	echo ">> Unzip WT binaries"
	unzip -qo ofm_webtier_linux_11.1.1.7.0_64_disk1_1of1.zip -d WT
fi

# RCU 11.1.1.8
[[ ! -d RCU_11118 ]] && mkdir RCU_11118 && echo "> Successfully created RCU directory"
if [[ "$(ls -A RCU_11118)" ]]; then
	echo ">> RCU directory is nonempty. Assuming unzip has already occurred."
else
	echo ">> Unzip RCU"
	unzip -qo ofm_rcu_linux_11.1.1.8.0_64_disk1_1of1.zip -d RCU_11118
fi

# Create central inventory
sudo ./WCC/Disk1/stage/Response/createCentralInventory.sh /u01/app/oraInventory oinstall