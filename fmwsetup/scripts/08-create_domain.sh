#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# March 18, 2015
#
# Create and extend WebLogic domain
#
# CHANGELOG
# 03/03/2015 - Changes WLST path to use environment
#			   variable instead of hard-coded value.
# 03/19/2015 - Reverted due to deployment errors
#			   (Str type cannot be None)

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

echo "> Begin domain creation"

cd $FMW_HOME/oracle_common/common/bin
./wlst.sh $RESP_DIR/domain_create.py