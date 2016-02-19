#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# July 15th, 2015
#
# Test for the existence of all required source files and patches
#
# CHANGELOG
# 02/19/2016 - Added file consistency checks

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
	sum=""
	check_sum=true
	if [[ ! -e $STAGE_DIR/${INSTALLER_LIST[$product]} ]]; then
		echo "!! Missing Installer: $product - ${INSTALLER_LIST[$product]}"
		all_ok=false
		check_sum=false
	fi
	if [[ "$check_sum" == true ]]; then
		printf "Found ${INSTALLER_LIST[$product]}, checking consistency.. Please wait.."
        sum=`sha1sum $STAGE_DIR/${INSTALLER_LIST[$product]} | awk '{print $1}'`
        if [[ $sum != ${INSTALLER_SUMS[$product]} ]]; then
                printf " FAILED\n"
                printf "!! Consistency check failed for ${INSTALLER_LIST[$product]}\n"
                all_ok=false
        else
                printf " PASSED!\n"
        fi
	fi
done
echo

# Check all patches
for patch in "${!PATCH_LIST[@]}"; do
	sum=""
	check_sum=true
	if [[ ! -e $STAGE_DIR/PATCHES/${PATCH_LIST[$patch]} ]]; then
		echo "!! Missing Patch: $patch - ${PATCH_LIST[$patch]}"
		all_ok=false
		check_sum=false
	fi
	if [[ "$check_sum" == true ]]; then
		printf "Found ${PATCH_LIST[$patch]}, checking consistency.. Please wait.."
        sum=`sha1sum $STAGE_DIR/PATCHES/${PATCH_LIST[$patch]} | awk '{print $1}'`
        if [[ $sum != ${PATCH_SUMS[$patch]} ]]; then
                printf " FAILED\n"
                printf "!! Consistency check failed for ${PATCH_LIST[$patch]}\n"
                all_ok=false
        else
                printf " PASSED!\n"
        fi
	fi
done

echo

# If failures occurred, sent failure signal back to caller
[[ "$all_ok" = false ]] && echo ">>> Errors occurred. Terminating deployment." && exit 2

echo ">>> All resource file checks passed. Deployment may proceed."