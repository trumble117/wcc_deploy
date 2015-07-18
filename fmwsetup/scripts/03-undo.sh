#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Deinstall WCC
#
# CHANGELOG
# 07/17/2015 - Added status tracking

spin() {
   local -a marks=( '/' '-' '\' '|' )
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

sleep 2
until [[ ! -z $INSTALL_PID ]]; do
        sleep 1
        INSTALL_PID=$(ps -ef | grep Doracle.installer.library_loc | grep -v grep | awk '{print $2}')
done

until [[ ! $(ps -ef | grep $INSTALL_PID | grep -v grep) ]]; do
        spin
done

INSTALL_TEST=$(grep "Completed deinstallation of Oracle Home" $LOG_FILE)
if [[ $INSTALL_TEST ]]; then
	echo "> WebCenter Content deinstallation has completed successfully!"
else
	echo "[FATAL] - Denstallation has finished, but did not complete successfully. Please examine the log file and try again when the issue has been resolved."
	exit 2
fi