# Johnathon Trumble
# john.trumble@oracle.com
# March 18 2015
#
# Perform WebTier configuration since we didn't do it at install-time (no domain)
#
# CHANGELOG
# 03/18/2015 - Removed admin password prompt, to grab from environment

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

ADM_PID=$(ps -ef | grep AdminServer | grep -v grep | awk '{print $2}')
if [[ ! $ADM_PID ]]; then
	echo "[WARNING] AdminServer must be running. Starting up..."
	[[ -z $WLS_DOMAIN ]] && . ~/.bash_profile
	python ~/wls_scripts/servercontrol.py --start=admin
	[[ $? != "0" ]] && echo "[> Halting script execution <]" && exit 2
fi

# Copy staticports.ini to a temporary location
# We have to do this because the name of the key in the response file has spaces in it
cp $RESP_DIR/staticports.ini /tmp

echo "> Launching wizard"
# Launch configuration wizard
$WT_HOME/bin/config.sh -silent -responseFile $RESP_DIR/config_ohs.rsp DOMAIN_USER_PASSWORD=$ADMIN_PW DOMAIN_HOST_NAME=$ADMIN_SERVER_HOST INSTANCE_HOME=$WT_INSTANCE_HOME INSTANCE_NAME=$OHS_INSTANCE_NAME

echo
echo "[IMPORTANT] - If you encounter an error at the end of configuration stating \"Failed to Start OHS Component\", please disregard it and move on to the next step."
echo "The cause of this error is known and expected for this deployment."