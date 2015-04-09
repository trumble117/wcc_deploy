#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# March 5, 2015
#
# Install one-off patches to WCC, WT, SOA, and WebLogic
#
# CHANGELOG
# 03/02/2015 - Updated patch list for January updates
#			 - Added SOA

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

patch_opatch(){
	mv $ORACLE_HOME/OPatch $ORACLE_HOME/OPatch-$(date +%y-%m-%d)
	unzip -qo $STAGE_DIR/PATCHES/p6880880_111000_Linux-x86-64.zip -d $ORACLE_HOME
}

# Patch Oracle Common OPatch
echo ">> Patching Oracle Common OPatch"
export ORACLE_HOME=$FMW_HOME/oracle_common
patch_opatch

# Patch WebCenter Content
echo ">> Starting patch process for Oracle WebCenter Content"
export ORACLE_HOME=$ECM_HOME
patch_opatch
# To get OCM response file, run $ORACLE_HOME/OPatch/ocm/bin/emocmrsp
$ORACLE_HOME/OPatch/opatch apply -silent -ocmrf $STAGE_DIR/../../responses/ocm.rsp -invPtrLoc /etc/oraInst.loc $STAGE_DIR/PATCHES/p20022599_111180_Generic.zip

# Patch WebCenter Content
echo ">> Starting patch process for Oracle SOA Suite"
export ORACLE_HOME=$SOA_HOME
patch_opatch
# To get OCM response file, run $ORACLE_HOME/OPatch/ocm/bin/emocmrsp
$ORACLE_HOME/OPatch/opatch apply -silent -ocmrf $STAGE_DIR/../../responses/ocm.rsp -invPtrLoc /etc/oraInst.loc $STAGE_DIR/PATCHES/p19953598_111170_Generic.zip

# Patch Web Tier
echo ">> Starting patch process for Oracle Web Tier"
export ORACLE_HOME=$WT_HOME
patch_opatch
# To get OCM response file, run $ORACLE_HOME/OPatch/ocm/bin/emocmrsp
$ORACLE_HOME/OPatch/opatch apply -silent -ocmrf $STAGE_DIR/../../responses/ocm.rsp -invPtrLoc /etc/oraInst.loc $STAGE_DIR/PATCHES/p18423831_111170_Linux-x86-64.zip

echo ">> Setting permissions on .apachectl for privileged port use"
# Set permissions to bind to privileged ports later
sudo chown root $ORACLE_HOME/ohs/bin/.apachectl
sudo chmod 6750 $ORACLE_HOME/ohs/bin/.apachectl

# Patch WebLogic
echo ">> Starting patch process for WebLogic Server"
export ORACLE_HOME=$WL_HOME
BSU_DIR=$FMW_HOME/utils/bsu
[[ ! -d $BSU_DIR/cache_dir ]] && mkdir $BSU_DIR/cache_dir
[[ ! -d $BSU_DIR/cache_dir/12UV ]] && mkdir $BSU_DIR/cache_dir/12UV
unzip -qo $STAGE_DIR/PATCHES/p19637463_1036_Generic.zip -d $BSU_DIR/cache_dir/12UV
# Sometimes BSU will fail if the patch catalog name is left default
cp $BSU_DIR/cache_dir/12UV/patch-catalog_22147.xml $BSU_DIR/cache_dir/12UV/patch-catalog.xml
# BSU won't run unless you run it from it's own directory
cd $BSU_DIR
$BSU_DIR/bsu.sh -install -patch_download_dir=$BSU_DIR/cache_dir/12UV -patchlist=12UV -prod_dir=$ORACLE_HOME

# Include xdo report library in UCM application deployment
echo ">> Modifying CS application deployment to include XDO runtime"
cd $ECM_HOME/ucm/idc/components/ServletPlugin
unzip -qo cs.ear META-INF/weblogic-application.xml
# Backup in case of revert
cp META-INF/weblogic-application.xml META-INF/weblogic-application.xml-BAK
sed -i 's/.*<\/weblogic-application>.*/\t<library-ref>\n\t\t<library-name>oracle.xdo.runtime<\/library-name>\n\t<\/library-ref>\n&/' META-INF/weblogic-application.xml
zip -qf cs.ear META-INF/weblogic-application.xml

echo "> Fusion Middleware patch application complete."