#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Deinstall WCC

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

echo "> Beginning WebCenter Content silent deinstall"
echo

LOG_FILE=$SCRIPTS_DIR/output/wcc-deinstall-$(date +%y-%m-%d_%H-%M-%S).log
if ! [[ -d $SCRIPTS_DIR/output ]]; then
	echo ">> Making output directory..."
	mkdir -p $SCRIPTS_DIR/output
fi
# Launch the installer
$ECM_HOME/oui/bin/runInstaller -jreloc $JAVA_HOME -deinstall -silent -responseFile $RESP_DIR/deinstall_wcc.rsp > $LOG_FILE 2>&1

echo
echo "> WebCenter Content silent deinstallation has been launched"
echo "> Monitor $LOG_FILE for progress"
