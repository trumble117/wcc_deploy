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