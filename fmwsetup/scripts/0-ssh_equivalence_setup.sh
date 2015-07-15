#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# April 3, 2015
#
# Setup SSH user equivalence for multinode configuration
#
# CHANGELOG

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

REMOTE_MACHINES=( "${MACHINE_LIST[@]/$HOSTNAME}" )
if [[ $MULTINODE == 1 ]]; then
	$MEDIA_BASE/scripts/sshUserSetup.sh -user oracle -hosts "${REMOTE_MACHINES[@]}" -noPromptPassphrase -confirm -advanced
	if [[ $? == 1 ]]; then
		echo "[FATAL] An error occurred during ssh equivalence setup. Please inspect the output, and try again"
		exit 2
	fi
else
	echo "> SSH equivalence unnecessary, since multinode was not selected."
	echo "> Please proceed to step 1"
fi