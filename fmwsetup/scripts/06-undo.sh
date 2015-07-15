#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# March 17, 2015
# 
# Upatch FMW products
#
# CHANGELOG
# 03/17/2015 - Added SOA
#			   Updated patch numbers
# 04/14/2015 - Updated to April patchset for SOA
# 07/15/2015 - Updated patch list for July 2015

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

rollback_opatch(){
	if [[ -d $ORACLE_HOME/OPatch-$(date +%y-%m-%d) ]]; then
		rm -rf $ORACLE_HOME/OPatch
		mv $ORACLE_HOME/OPatch-$(date +%y-%m-%d) $ORACLE_HOME/OPatch
	fi
}

# Patch Oracle Common OPatch
echo ">> Unpatching Oracle Common OPatch"
export ORACLE_HOME=$FMW_HOME/oracle_common
rollback_opatch

# Patch WebCenter Content
echo ">> Unpatching Oracle WebCenter Content"
export ORACLE_HOME=$ECM_HOME
$ORACLE_HOME/OPatch/opatch rollback -silent -invPtrLoc /etc/oraInst.loc -id 21168615
rollback_opatch

# NO PATCH FOR WEB TIER 11.1.1.9 YET
# Patch Web Tier
#echo ">> Unpatching Oracle Web Tier"
#export ORACLE_HOME=$WT_HOME
# Rollback permissions
#sudo chmod 750 $ORACLE_HOME/ohs/bin/.apachectl
#sudo chown oracle $ORACLE_HOME/ohs/bin/.apachectl
$ORACLE_HOME/OPatch/opatch rollback -silent -invPtrLoc /etc/oraInst.loc -id 18423831
#rollback_opatch

# Patch SOA Suite
echo ">> Unpatching Oracle SOA Suite"
export ORACLE_HOME=$SOA_HOME
$ORACLE_HOME/OPatch/opatch rollback -silent -invPtrLoc /etc/oraInst.loc -id 20900797
rollback_opatch
export ORACLE_HOME=$FMW_HOME/oracle_common
$ORACLE_HOME/OPatch/opatch rollback -silent -invPtrLoc /etc/oraInst.loc -id 20900797
rollback_opatch

# Patch WebLogic
echo ">> Unpatching WebLogic Server"
export ORACLE_HOME=$WL_HOME
BSU_DIR=$FMW_HOME/utils/bsu
# Required for BSU execution
cd $BSU_DIR
$BSU_DIR/bsu.sh -remove -patchlist=EJUW -prod_dir=$ORACLE_HOME

# Remove xdo report library in UCM application deployment
echo ">> Removing XDO runtime from CS application"
cd $ECM_HOME/ucm/idc/components/ServletPlugin
cp META-INF/weblogic-application.xml-BAK META-INF/weblogic-application.xml
zip -qf cs.ear META-INF/weblogic-application.xml
rm -rf META-INF

echo "> Unpatch complete."
