#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# CHANGELOG
# 07/17/2015 - Added status tracking

spin() {
   local -a marks=( 'Please wait /' 'Please wait -' 'Please wait \' 'Please wait |' )
   count=0
   while [[ $count < 30 ]]; do
     printf '%s\r' "${marks[i++ % ${#marks[@]}]}"
     sleep 1
     count=$((count + 1))
   done
}

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
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

sleep 5
until [[ ! -z $INSTALL_PID ]]; do
        sleep 1
        INSTALL_PID=$(ps -ef | grep Doracle.installer.library_loc | grep -v grep | awk '{print $2}')
done

until [[ ! $(ps -ef | grep $INSTALL_PID | grep -v grep) ]]; do
        spin
done

INSTALL_TEST=$(grep "Oracle WebTier and Utilities CD completed successfully" $LOG_FILE)
if [[ $INSTALL_TEST ]]; then
	echo "> Web Tier installation has completed successfully!"
else
	echo "[FATAL] - Installation has finished, but did not complete successfully. Please examine the log file and try again when the issue has been resolved."
	exit 2
fi