# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Perform WebTier configuration since we didn't do it at install-time (no domain)

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

ADM_PID=$(ps -ef | grep AdminServer | grep -v grep | awk '{print $2}')
if [[ ! $ADM_PID ]]; then
	echo "[WARNING] AdminServer must be running. Starting up..."
	. ~/.bash_profile
	python ~/wls_scripts/servercontrol.py --start=admin
	[[ $? != "0" ]] && echo "[> Halting script execution <]" && exit 2
fi

echo "Enter the weblogic user password:"
read -s adminpw

#INSTANCE_NAME=$(echo $WT_INSTANCE_HOME | awk -F/ '{print $NF}')

# Copy staticports.ini to a temporary location
# We have to do this because the name of the key in the response file has spaces in it
cp $RESP_DIR/staticports.ini /tmp

echo "> Launching wizard"
# Launch configuration wizard
$WT_HOME/bin/config.sh -silent -responseFile $RESP_DIR/config_ohs.rsp DOMAIN_USER_PASSWORD=$adminpw DOMAIN_HOST_NAME=$ADMIN_SERVER_HOST INSTANCE_HOME=$WT_INSTANCE_HOME INSTANCE_NAME=$OHS_INSTANCE_NAME
