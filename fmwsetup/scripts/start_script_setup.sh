#!/bin/sh

# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Helper script installation

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

if [[ -d ~/wls_scripts ]] && [[ "$(ls -A ~/wls_scripts)" ]]; then
	echo ">> Scripts directory already exists. This setup has already been performed, or oracle's home resides in a shared location"
	echo ">> If this is in error, remove $SCRIPTS_DIR and try again"
else
	echo ">> Copying script files"
	cd $SCRIPTS_DIR
	unzip -qo wls_scripts.zip -d ~/
	
	DOMAIN_NAME_UPPER=$(echo $DOMAIN_NAME | tr 'a-z' 'A-Z')
	echo ">> Creating properties file"
	cat << EOF > ~/wls_scripts/serverproperties.cfg
[$DOMAIN_NAME_UPPER]
fmw_home = $FMW_HOME
domain_home = $DOMAIN_HOME
admin_port = 7001
nm_port = $NM_PORT
log_dir = $LOG_DIR
EOF
	
	[[ $(grep "WLS_DOMAIN" ~/.bashrc) ]] && echo ">>> Deleting existing domain entry in profile" && sed -i '/WLS_DOMAIN/d' ~/.bashrc
	echo ">> Setting environment variables and aliases"
	cat << EOF >> ~/.bashrc
WLS_DOMAIN=$DOMAIN_NAME_UPPER
export WLS_DOMAIN
EOF

	# Make immediately available
	export WLS_DOMAIN=$DOMAIN_NAME
	
	[[ $(grep "servercontrol.py" ~/.bashrc) ]] && echo ">>> Deleting existing alias in profile" && sed -i '/servercontrol.py/d' ~/.bashrc
	echo "alias wls=\"python ~/wls_scripts/servercontrol.py\"" >> ~/.bashrc
	
	echo "> Script setup complete. The 'wls' utility will be available in this environment on next login"
fi