#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# April 9, 2015
#
# Deploy start scripts to all nodes


# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

cd $MEDIA_BASE/scripts

# Loop through all machines and deploy start scripts
for NODE in ${MACHINE_LIST[*]}; do
	if [[ $NODE == $(hostname) ]]; then
		echo ">> Deploying start scripts on local machine"
		./start_script_setup.sh
	else
        ssh -o StrictHostKeyChecking=no -t oracle@$NODE "[[ -d $MEDIA_BASE ]] && exit 1 || exit 0"
        if [[ $? == 0 ]]; then
                echo ">>> Media base does not exist on remote host. Ensure that these scripts are accessible via a mount point and try again"
                exit 2
        fi
        echo ">> Deploying start scripts on node $NODE"
        ssh -o StrictHostKeyChecking=no -t oracle@$NODE "cd $MEDIA_BASE/scripts; ./start_script_setup.sh"
	fi
	if [[ $? == 1 ]]; then
		echo "[FATAL] An error occurred during start script deployment. Please inspect the output, correct the error, and try again"
		echo ">> [NODE IN ERROR]: $NODE"
		cleanup
		exit 2
	fi	
done