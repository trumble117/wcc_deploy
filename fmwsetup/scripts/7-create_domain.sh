#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# March 3, 2015
#
# Create and extend WebLogic domain
#
# CHANGELOG
# 03/03/2015 - Changes WLST path to use environment
#			   variable instead of hard-coded value.

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

. $FMW_HOME/wlserver_10.3/server/bin/setWLSEnv.sh
echo "> Begin domain creation"

$JAVA_HOME/bin/java weblogic.WLST $RESP_DIR/domain_create.py