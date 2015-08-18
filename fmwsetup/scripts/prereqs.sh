#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# March 2, 2015
#
# Configure all system prerequisites prior to software installation and configuration
#
# CHANGELOG
# 03/02/2015 - Added SOA, Updated Patch Registry
# 04/17/2015 - Fixed bug: iptables still denying traffic, particularly
#			   to nodemanager. Due to DENY ALL above all custom port rules
# 07/15/2015 - Updated patch list for July 2015

create_error () {
	echo "$1"
	echo ">> [NODE IN ERROR]: $HOSTNAME"
	exit 2
}

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

THIS_USER=$(whoami)
[[ $THIS_USER != "oracle" ]] && create_error ">> Please run these scripts as oracle. <<"

LOCAL_DIRS=($FMW_HOME $DOMAIN_BASE)
MULTI_DIRS=($FMW_HOME $DOMAIN_BASE/$DOMAIN_NAME/aserver $INTRADOC_DIR $DOMAIN_BASE/$DOMAIN_NAME/resources $LOG_DIR)

# Test for sudo privileges
sudo -n touch SUDOtest
if [[ ! -a SUDOtest ]]; then
	echo "> User oracle does not have the sufficient privileges to SUDO on this machine."
	echo "> Execute $PWD/fixSudo.sh as a root user to fix privileges before continuing."
	echo
	
	cat << EOF > fixSudo.sh
echo "oracle	ALL=(ALL)	NOPASSWD: ALL" > /etc/sudoers.d/oracle
EOF
	create_error ">> Setup will now exit"
fi
[[ -a SUDOtest ]] && rm -f SUDOtest
[[ -a fixSudo.sh ]] && rm -f fixSudo.sh

# Test if oinstall exists - add oracle to it
[[ ! $(grep oinstall /etc/group) ]] && sudo groupadd oinstall
[[ ! $(grep oinstall /etc/group) ]] && create_error ">> [FATAL] Failed to create oinstall group"
if [[ ! $(groups | grep oinstall) ]]; then
	sudo usermod -a -G oinstall oracle || create_error ">> [FATAL] Failed to add oracle to oinstall group"
	echo "WARNING: You must now log out and back in to refresh user group membership before proceeding!"
	create_error ">> Setup will now exit"
fi
echo "> The group 'oinstall' exists and user 'oracle' is a member"

# Ensure required packages are installed
sudo yum clean all
sudo yum install -y $(cat $RESP_DIR/linux_required_packages.txt)

# Test for required filesystem directories
echo "> Running directory checks.."
if [[ $MULTINODE == 0 ]]; then
	for DIR in ${LOCAL_DIRS[@]}; do
		if [[ ! -d $DIR ]]; then
			echo ">> Creating $DIR"
			sudo mkdir -p $DIR || create_error ">> [FATAL] Failed to create $DIR"
			sudo chown oracle:oinstall $DIR || create_error ">> [FATAL] Failed to set permissions for $DIR"
		fi
	done
elif [[ $MULTINODE == 1 ]]; then
	echo "> If a location is not present, we will create it now, but the installer will exit so you can mount it to an NFS resource."
	for DIR in ${MULTI_DIRS[@]}; do
		if [[ ! -d $DIR ]]; then
			echo "> Creating $DIR"
			sudo mkdir -p $DIR || create_error ">> [FATAL] Failed to create $DIR"
			sudo chown oracle:oinstall $DIR || create_error ">> [FATAL] Failed to set permissions for $DIR"
			REM_LIST="$REM_LIST\n$DIR"
		fi
	done
	if [[ -n $REM_LIST ]]; then
		echo ">> The following directories were not found, and had to be created:"
		echo -e $REM_LIST
		echo 
		echo ">> These directories are required to reside on shared storage for multinode deployment."
		echo ">> Please mount these directories to an NFS or shared location, then re-run this step."
		create_error ">> Setup will now exit"
	fi
fi
echo ">> Filesystem directory checks passed."

# Test directory permissions
echo "> Running directory permissions checks.."
if [[ $MULTINODE == 0 ]]; then
	for DIR in ${LOCAL_DIRS[@]}; do
		TEST=$(stat -c "%U %G" $DIR)
		if [[ $TEST != "oracle oinstall" ]]; then
			echo ">> Modifying permissions for $DIR"
			sudo chown -R oracle:oinstall $DIR || create_error ">> [FATAL] Failed to set permissions for $DIR"
		fi
	done
elif [[ $MULTINODE == 1 ]]; then
	for DIR in ${MULTI_DIRS[@]}; do
		TEST=$(stat -c "%U %G" $DIR)
		if [[ $TEST != "oracle oinstall" ]]; then
			echo ">> Modifying permissions for $DIR"
			sudo chown -R oracle:oinstall $DIR || create_error ">> [FATAL] Failed to set permissions for $DIR"
		fi
	done
fi
echo ">> Directory permissions checks passed."

sudo yum install -y $STAGE_DIR/${INSTALLER_LIST[Java_JDK]}
export PATH=$PATH:$JAVA_HOME/bin

# Test if all server hostnames are resolvable
echo ">> Running hostname resolution checks..."
for HOST in $MACHINE_LIST
do
    ping -c 5 -w 5 $HOST
	EXITCODE=`echo $?`
	if [ $EXITCODE == 0 ]
	then
	    ALIVEHOSTS="$ALIVEHOSTS $HOST"
	else
	    DEADHOSTS="$DEADHOSTS $HOST"
	fi
done

if [[ -n $DEADHOSTS ]]; then
	create_error "[FATAL] The following hosts were not accessible: ${DEADHOSTS[*]}"
fi

# Check NFS mounting
if [[ $MULTINODE == 1 ]]; then
	for DIR in ${MULTI_DIRS[@]}; do
		if [[ ! -f $FMW_HOME/test.nfs ]]; then
			NO_FILE="$NO_FILE\n$DIR"
		fi
	done
	if [[ -n $NO_FILE ]]; then
		echo ">> [FATAL] Could not locate shared resources at the following locations:"
		echo -e $NO_FILE
		echo
		echo ">> Please ensure that all nodes are mounted to the same shared storage locations for the above and run this step again."
		create_error ">> Setup will now exit"
	else
		echo "> Shared filesystem checks passed"
	fi
fi

# Modify firewall configuration
if [[ -z $(sudo grep 7001 /etc/sysconfig/iptables) ]]; then
	echo ">> Modifying firewall configuration"
	sudo bash -c "iptables-save > /etc/sysconfig/iptables-BAK"
	sudo iptables -D INPUT -j REJECT --reject-with icmp-host-prohibited
	sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
	sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
	sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 7001 -j ACCEPT
	sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 16200 -j ACCEPT
	sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 16250 -j ACCEPT
	sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 16400 -j ACCEPT
	sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 16300 -j ACCEPT
	sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 16000 -j ACCEPT
	sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 8001 -j ACCEPT
	sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport $NM_PORT -j ACCEPT
	sudo iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 9998 -j ACCEPT
	sudo iptables -A INPUT -j REJECT --reject-with icmp-host-prohibited
	sudo bash -c "iptables-save > /etc/sysconfig/iptables"
	[[ $? == 1 ]] && create_error ">> [FATAL] Firewall rules were not successfully saved."
else
	echo ">> Firewall rules already present on this machine"
fi

echo "> DONE"

#PATCH REGISTRY
#
# WebCenter Content - p21168615_111180_Generic.zip [Bundle Patch 13 (July 2015)]
# Oracle SOA Suite - p20900797_111170_Generic.zip [Bundle Patch 8 (July 2015)]
# Oracle WebLogic Server - p20780171_1036_Generic.zip [EJUW (July 2015)]
# Oracle OPatch - p6880880_111000_Linux-x86-64.zip [11.1.0.12.7 (July 2015)]
