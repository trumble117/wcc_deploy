# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Undo OHS proxy configuration

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

echo ">> Reverting configuration files"

# Revert original config
cp $WT_INSTANCE_HOME/config/OHS/$OHS_NAME/mod_wl_ohs.conf-BAK $WT_INSTANCE_HOME/config/OHS/$OHS_NAME/mod_wl_ohs.conf
cp $WT_INSTANCE_HOME/config/OHS/$OHS_NAME/ssl.conf-BAK $WT_INSTANCE_HOME/config/OHS/$OHS_NAME/ssl.conf

echo ">> Configuration reverted, restarting services..."

# Restart services
$WT_INSTANCE_HOME/bin/opmnctl stopall
sleep 5
$WT_INSTANCE_HOME/bin/opmnctl startall