# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Undo webtier configuration

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

# Check environment variables
if [[ -z $WT_INSTANCE_HOME ]] || [[ ! -d $WT_INSTANCE_HOME ]]; then
	echo "Please set a valid Web Tier Instance Home directory in your environment"
	echo "export WT_INSTANCE_HOME=/u01/app/oracle/admin/ohs_instance1"
	echo
	echo "Or use the environment setup script provided in this directory"
	exit 2
fi

echo ">> Unregister instance from domain"
$WT_INSTANCE_HOME/bin/opmnctl unregisterinstance

sleep 5
echo ">> Delete instance from disk"
sudo $WT_INSTANCE_HOME/bin/opmnctl deleteinstance

sleep 5
echo ">> Force remove instance directories from disk"
rm -rf $WT_INSTANCE_HOME

echo "> WebTier unconfiguration complete"