#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# March 5, 2015
#
# Install SOA binaries to FMW Home
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

echo "> Beginning SOA Suite Silent Install"
echo ">> Response File: $RESP_DIR/install_soa.rsp"
echo

LOG_FILE=$SCRIPTS_DIR/output/soa-install-$(date +%y-%m-%d_%H-%M-%S).log
if ! [[ -d $SCRIPTS_DIR/output ]]; then
	echo ">> Making output directory..."
	mkdir -p $SCRIPTS_DIR/output
fi
# Launch the installer
$STAGE_DIR/SOA/Disk1/runInstaller -jreloc $JAVA_HOME -silent -responseFile $RESP_DIR/install_soa.rsp -invPtrLoc /etc/oraInst.loc > $LOG_FILE 2>&1

echo
echo "> SOA Suite Silent Installation has been launched"
echo "> Monitor $LOG_FILE for progress"

sleep 5
until [[ ! -z $INSTALL_PID ]]; do
        sleep 1
        INSTALL_PID=$(ps -ef | grep Doracle.installer.library_loc | grep -v grep | awk '{print $2}')
done

until [[ ! $(ps -ef | grep $INSTALL_PID | grep -v grep) ]]; do
        spin
done

INSTALL_TEST=$(grep "Oracle SOA Suite 11g completed successfully" $LOG_FILE)
if [[ $INSTALL_TEST ]]; then
	echo "> Oracle SOA Suite installation has completed successfully!"
else
	echo "[FATAL] - Installation has finished, but did not complete successfully. Please examine the log file and try again when the issue has been resolved."
	exit 2
fi