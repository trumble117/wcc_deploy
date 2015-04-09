#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# April 9, 2015
#
# Post-domain-extension configuration script for remote nodes

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

if [[ -f $TEMPLATE_DIR/$DOMAIN_NAME-packd.jar ]]; then
	echo ">>> Unpacking the domain to $MSERVER_HOME..."
	$FMW_HOME/oracle_common/common/bin/unpack.sh -domain=$MSERVER_HOME -template=$TEMPLATE_DIR/$DOMAIN_NAME-packd.jar -app_dir=$APP_HOME -overwrite_domain=true
else
	echo "[FATAL] Domain template does not exist or is inaccessible."
	exit 1
fi

# Start NodeManager
NM_PID=$(ps -ef | grep weblogic.NodeManager | grep -v grep | awk '{print $2}')
if [[ ! $NM_PID ]]; then
        echo "Starting up NodeManager..."
    	[[ -z $WLS_DOMAIN ]] && . ~/.bash_profile
        python ~/wls_scripts/servercontrol.py --start=nodemanager
        [[ $? != "0" ]] && echo "[> Halting script execution <]" && echo ">> [NODE IN ERROR]: $HOSTNAME" && exit 2
fi