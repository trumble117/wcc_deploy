#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Uninstall WebLogic Server

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

echo "> Beginning WLS Silent Uninstallation"
echo

$WL_HOME/uninstall/uninstall.sh -mode=silent -log=$SCRIPTS_DIR/output/weblogic_uninstall-$(date +%y-%m-%d_%H-%M-%S).log

RETVAL=$?
if [[ $RETVAL -eq 0 ]]; then
	echo "WebLogic was uninstalled successfully!"
elif [[ $RETVAL -eq 1 ]]; then
	echo "[FATAL] uninstallation failed due to fatal error."
	exit 2
else
	echo "[FATAL] uninstallation failed due to XML parsing error."
	exit 2
fi
