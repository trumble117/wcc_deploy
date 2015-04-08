#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

echo "> Beginning WebTier Utilities Silent Install"
echo ">> Response File: $RESP_DIR/install_wt.rsp"

LOG_FILE=$SCRIPTS_DIR/output/wt-install-$(date +%m-%d-%y_%H-%M-%S).log
if ! [[ -d $SCRIPTS_DIR/output ]]; then
	echo ">> Making output directory..."
	mkdir -p $SCRIPTS_DIR/output
fi
# Launch the installer
$STAGE_DIR/WT/Disk1/runInstaller -silent -responseFile $RESP_DIR/install_wt.rsp > $LOG_FILE 2>&1

echo
echo "> WebTier Utilities Silent Installation has been launched"
echo "> Monitor $LOG_FILE for progress"
