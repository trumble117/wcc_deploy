# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Perform initial configuration of WebCenter Content + IBR

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

[[ ! -d $MSERVER_HOME/ucm/cs/bin ]] && echo ">>> Creating bin directory in $MSERVER/ucm/cs" && mkdir -p $MSERVER_HOME/ucm/cs/bin
[[ ! -s $MSERVER_HOME/ucm/cs/bin/autoinstall.cfg ]] && echo ">>> [DEBUG] Creating empty $MSERVER_HOME/ucm/cs/bin/autoinstall.cfg" && touch $MSERVER_HOME/ucm/cs/bin/autoinstall.cfg
echo ">>> Writing autoinstall config to $MSERVER_HOME/ucm/cs/bin/autoinstall.cfg"
UCMIDC="$SCHEMA_PREFIX"_wcc
DOCPREFIX="$SCHEMA_PREFIX"_
cat << EOF > $MSERVER_HOME/ucm/cs/bin/autoinstall.cfg
IDC_Name=$UCMIDC
IDC_ID=UCM_server1
InstanceMenuLabel=$SCHEMA_PREFIX WCC
InstanceDescription=$SCHEMA_PREFIX WebCenter Content Instance
AutoInstallComplete=true
AutoNumberPrefix=$DOCPREFIX
IsAutoNumber=1
IntradocServerPort=4444
SocketHostAddressSecurityFilter=127.0.0.1|*.*.*.*
HttpServerAddress=$UCM_HOST
MailServer=mail
SysAdminAddress=sysadmin@example.com
HttpRelativeWebRoot=/cs/
UseSSL=No
SearchIndexerEngineName=OracleTextSearch
IntradocDir=$INTRADOC_DIR/cs/
VaultDir=$INTRADOC_DIR/cs/vault/
WeblayoutDir=$INTRADOC_DIR/cs/weblayout/
UserProfilesDir=$INTRADOC_DIR/cs/data/users/profiles/
EOF

[[ ! -d $MSERVER_HOME/ucm/ibr/bin ]] && echo ">>> Creating bin directory in $MSERVER_HOME/ucm/ibr" && mkdir -p $MSERVER_HOME/ucm/ibr/bin
[[ ! -s $MSERVER_HOME/ucm/ibr/bin/autoinstall.cfg ]] && echo ">>> [DEBUG] Creating empty $MSERVER_HOME/ucm/ibr/bin/autoinstall.cfg" && touch $MSERVER_HOME/ucm/ibr/bin/autoinstall.cfg
echo ">>> Writing autoinstall config to $MSERVER_HOME/ucm/ibr/bin/autoinstall.cfg"
IBRIDC="$SCHEMA_PREFIX"_ibr
cat << EOF > $MSERVER_HOME/ucm/ibr/bin/autoinstall.cfg
IDC_ID=IBR_server1
IDC_Name=$IBRIDC
InstanceMenuLabel=$SCHEMA_PREFIX IBR
InstanceDescription=$SCHEMA_PREFIX Content IBR Instance
AutoInstallComplete=true
SocketHostAddressSecurityFilter=127.0.0.1|*.*.*.*
HttpServerAddress=$UCM_HOST
HttpRelativeWebRoot=/ibr/
UseSSL=false
IntradocServerPort=5555
FmwDomainConfigDir=$MSERVER_HOME/config/fmwconfig/
IntradocDir=$INTRADOC_DIR/ibr/
VaultDir=$INTRADOC_DIR/ibr/vault/
WeblayoutDir=$INTRADOC_DIR/ibr/weblayout/
UserProfilesDir=$INTRADOC_DIR/ibr/data/users/profiles/
EOF
