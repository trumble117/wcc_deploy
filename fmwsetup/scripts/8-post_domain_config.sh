#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Post-domain-extension configuration script

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

NM_START_TIMEOUT=120

usage(){
	echo "~*~* Run as the oracle install user _after_ creating/extending the domain *~*~"
	echo
	echo " Fill in all information in the provide[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . setScriptEnv.sh"
}

punpack(){
	APP_HOME=${MSERVER_HOME/mserver\/*/mserver\/applications}
	[[ -e $TEMPLATE_DIR/$DOMAIN_NAME-packd.jar ]] && rm -f $TEMPLATE_DIR/$DOMAIN_NAME-packd.jar
	echo ">>> Packing up the domain from $DOMAIN_HOME..."
	$FMW_HOME/oracle_common/common/bin/pack.sh -managed=true -domain=$DOMAIN_HOME -template=$TEMPLATE_DIR/$DOMAIN_NAME-packd.jar -template_name=$DOMAIN_NAME
	
	echo ">>> Unpacking the domain to $MSERVER_HOME..."
	$FMW_HOME/oracle_common/common/bin/unpack.sh -domain=$MSERVER_HOME -template=$TEMPLATE_DIR/$DOMAIN_NAME-packd.jar -app_dir=$APP_HOME -overwrite_domain=true
}

# MAIN
[[ $1 == "usage" ]] && usage && exit 1

# Get username/password for 'weblogic' user from the operator
username="weblogic"
#echo "Enter $username's password: "
#read -s password
password=$ADMIN_PW

# Test if the security directory exists yet. If not, create it
# It should not exist unless you've tried to start the AdminServer once
if [[ ! -d $DOMAIN_HOME/servers/AdminServer/security ]]
then
	echo "~~>> Security directory not found - generating..."
	mkdir -p $DOMAIN_HOME/servers/AdminServer/security
fi

# Populate the boot.properties file based on user input
echo ">> Setting boot identity for domain startup..."
cat << EOF > $DOMAIN_HOME/servers/AdminServer/security/boot.properties
username=$username
password=$password
EOF

# Edit the nodemanager properties file to allow start scripts
# Without this set to true, the environment will fail to be set properly
# during server start and the managed servers will start in ADMIN mode
echo ">> Editing nodemanager properties..."
if [[ -s $FMW_HOME/wlserver_10.3/common/nodemanager/nodemanager.properties ]]; then
	sed -i 's/StartScriptEnabled=false/StartScriptEnabled=true/g' $FMW_HOME/wlserver_10.3/common/nodemanager/nodemanager.properties
else
	cat << EOF > $FMW_HOME/wlserver_10.3/common/nodemanager/nodemanager.properties
#$(date)
DomainsFile=$WL_HOME/common/nodemanager/nodemanager.domains
LogLimit=0
PropertiesVersion=10.3
DomainsDirRemoteSharingEnabled=false
javaHome=$JAVA_HOME
AuthenticationEnabled=true
NodeManagerHome=$WL_HOME/common/nodemanager
JavaHome=$JAVA_HOME/jre
LogLevel=INFO
DomainsFileEnabled=true
StartScriptName=startWebLogic.sh
ListenAddress=
NativeVersionEnabled=true
ListenPort=$NM_PORT
LogToStderr=true
SecureListener=true
LogCount=1
DomainRegistrationEnabled=false
StopScriptEnabled=false
QuitEnabled=false
LogAppend=true
StateCheckInterval=500
CrashRecoveryEnabled=false
StartScriptEnabled=true
LogFile=$WL_HOME/common/nodemanager/nodemanager.log
LogFormatter=weblogic.nodemanager.server.LogFormatter
ListenBacklog=50
EOF
fi

# Set USER_MEM_ARGS for JDK7
sed -i 's/.*export SUN_JAVA_HOME.*/&\n\nUSER_MEM_ARGS=\"-Xms32m -Xmx200m -XX:MaxPermSize=350m\"\nexport USER_MEM_ARGS/' $DOMAIN_HOME/bin/setDomainEnv.sh

# Create logs directory
mkdir -p $LOG_DIR

# Pack/Unpack operations
echo ">> Performing a pack/unpack..."
punpack

# Disable hostname verification
ADM_PID=$(ps -ef | grep AdminServer | grep -v grep | awk '{print $2}')
if [[ ! $ADM_PID ]]; then
        echo "[WARNING] AdminServer must be running. Starting up..."
        . ~/.bash_profile
        python ~/wls_scripts/servercontrol.py --start=admin
        [[ $? != "0" ]] && echo "[> Halting script execution <]" && exit 2
fi

cd $FMW_HOME/oracle_common/common/bin/
./wlst.sh $RESP_DIR/disable_hostname_verification.py

# Shut down AdminServer
python ~/wls_scripts/servercontrol.py --stop=admin

echo "> DONE!"
