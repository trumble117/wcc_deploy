#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# March 2, 2015
#
# Deinstall SOA

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

echo "> Beginning SOA Suite silent deinstall"
echo

LOG_FILE=$SCRIPTS_DIR/output/soa-deinstall-$(date +%y-%m-%d_%H-%M-%S).log
if ! [[ -d $SCRIPTS_DIR/output ]]; then
	echo ">> Making output directory..."
	mkdir -p $SCRIPTS_DIR/output
fi
# Launch the installer
$SOA_HOME/oui/bin/runInstaller -jreloc $JAVA_HOME -deinstall -silent -responseFile $RESP_DIR/deinstall_soa.rsp > $LOG_FILE 2>&1

echo
echo "> SOA Suite silent deinstallation has been launched"
echo "> Monitor $LOG_FILE for progress"
