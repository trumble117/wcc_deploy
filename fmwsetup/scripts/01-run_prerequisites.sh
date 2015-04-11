#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# April 4, 2015
#
# Configure all system prerequisites prior to software installation and configuration


cleanup () {
# Remove temporary NFS files
if [[ $MULTINODE == 1 ]]; then
	echo "Cleaning up..."
	rm -f $FMW_HOME/test.nfs
	rm -f $DOMAIN_BASE/$DOMAIN_NAME/aserver/test.nfs
	rm -f $INTRADOC_DIR/test.nfs
	rm -f $DOMAIN_BASE/$DOMAIN_NAME/resources/test.nfs
	rm -f $LOG_DIR/test.nfs
fi
}

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

cd $MEDIA_BASE/scripts

# Unzip installers from this machine
./unzip_installers.sh

# Place temporary files for NFS checks
if [[ $MULTINODE == 1 ]]; then
	touch $FMW_HOME/test.nfs
	touch $DOMAIN_BASE/$DOMAIN_NAME/aserver/test.nfs
	touch $INTRADOC_DIR/test.nfs
	touch $DOMAIN_BASE/$DOMAIN_NAME/resources/test.nfs
	touch $LOG_DIR/test.nfs
fi

# Loop through all machines and run prerequisites
for NODE in ${MACHINE_LIST[*]}; do
	if [[ $NODE == $(hostname) ]]; then
		echo ">> Executing prerequisites on local machine"
		./prereqs.sh
	else
        ssh -o StrictHostKeyChecking=no -t oracle@$NODE "[[ -d $MEDIA_BASE ]] && exit 1 || exit 0"
        if [[ $? == 0 ]]; then
                echo ">>> Media base does not exist on remote host. Ensure that these scripts are accessible via a mount point and try again"
                exit 2
        fi
        echo ">> Executing prerequisites on node $NODE"
        ssh -o StrictHostKeyChecking=no -t oracle@$NODE "cd $MEDIA_BASE/scripts; ./prereqs.sh"
	fi
	if [[ $? == 2 ]]; then
		echo "[FATAL] An error occurred during prerequsite execution. Please inspect the output, correct the error, and try again"
		echo ">> [NODE IN ERROR]: $NODE"
		cleanup
		exit 2
	fi	
done

cleanup