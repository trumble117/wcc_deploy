#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# March 18, 2015
#
# Back out domain creation
#
# CHANGELOG
# 03/18/2015 - Added sudo to domain deletion for root owned files

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

ADM_PID=$(ps -ef | grep AdminServer | grep -v grep | awk '{print $2}')
NM_PID=$(ps -ef | grep weblogic.Nodemanager | grep -v grep | awk '{print $2}')
[[ $ADM_PID ]] && kill -9 $ADM_PID && echo "Killed AdminServer PID $ADM_PID" || echo "> AdminServer is shut down"
[[ $NM_PID ]] && kill -9 $NM_PID && echo "Killed Node Manager PID $NM_PID" || echo "> Node Manager is shut down"

# Remove the domain from the registry
echo ">> Editing domain registry"
cp $FMW_HOME/domain-registry.xml $FMW_HOME/domain-registry.xml-BAK
sed -i "/$DOMAIN_NAME/d" $FMW_HOME/domain-registry.xml

# Remove the domain from the nodemanager domains file
echo ">> Editing nodemanager.domains"
cp $FMW_HOME/wlserver_10.3/common/nodemanager/nodemanager.domains $FMW_HOME/wlserver_10.3/common/nodemanager/nodemanager.domains-BAK
sed -i "/$DOMAIN_NAME/d" $FMW_HOME/wlserver_10.3/common/nodemanager/nodemanager.domains

# Delete the domain directory
echo ">> Deleting domain from disk"
sudo rm -rf $DOMAIN_BASE

echo "> Domain delete complete"