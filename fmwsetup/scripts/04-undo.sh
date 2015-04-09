#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Deinstall Web Tier

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

echo "> Beginning Web Tier silent deinstall"
echo

LOG_FILE=$SCRIPTS_DIR/output/wt-deinstall-$(date +%y-%m-%d_%H-%M-%S).log
if ! [[ -d $SCRIPTS_DIR/output ]]; then
	echo ">> Making output directory..."
	mkdir -p $SCRIPTS_DIR/output
fi
# Launch the installer
cd $WT_HOME
$WT_HOME/oui/bin/runInstaller -deinstall -silent -responseFile $RESP_DIR/deinstall_wt.rsp > $LOG_FILE 2>&1

echo
echo "> Web Tier silent deinstallation has been launched"
echo "> Monitor $LOG_FILE for progress"