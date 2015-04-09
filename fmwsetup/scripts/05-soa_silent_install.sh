#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# March 5, 2015
#
# Install SOA binaries to FMW Home

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
