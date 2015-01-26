# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Undo intial configuration of WebCenter Content + IBR

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

echo "NOTE: This is not effective if UCM has been launched already"

echo "> Deleting $MSERVER_HOME/ucm/cs/bin/autoinstall.cfg"
rm $MSERVER_HOME/ucm/cs/bin/autoinstall.cfg

echo "> Deleting $MSERVER_HOME/ucm/ibr/bin/autoinstall.cfg"
rm $MSERVER_HOME/ucm/ibr/bin/autoinstall.cfg