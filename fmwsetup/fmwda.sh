#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# March 2, 2015
#
# FMW Deployment Assistant
#
# CHANGELOG
# 03/02/2015 - Modified to accommodate SOA
# 03/19/2015 - Edited to reflect new machine names
#			   Added option for start mode
# 04/13/2015 - Streamlined to assume more information 
#			   and ask fewer questions for single node 
#			   deployments
# 06/17/2015 - Added WSMPM resources (separated from SOA,
#			   per documentation recommendation).


[[ ! -e scripts/setScriptEnv.sh ]] && echo "Something's not right, setScriptEnv.sh does not exist in the scripts directory. Exiting..." && exit 2

echo "  ___ __  ____      _____   _    "
echo " | __|  \/  \ \    / /   \ /_\   "
echo " | _|| |\/| |\ \/\/ /| |) / _ \  "
echo " |_| |_|  |_| \_/\_/ |___/_/ \_\ "
echo
echo "Just answer a few questions about your deployment so we can get everything set up"
echo

# READ ANSWERS
# Base variables
echo "Where will your Middleware Home be? [/u01/app/oracle/product/fmw]"
read FMW_HOME
[[ -z $FMW_HOME ]] && FMW_HOME="/u01/app/oracle/product/fmw"

echo "Where will your \"base\" directory for FMW domain(s) be? [/u01/app/oracle/admin]"
read DOMAIN_BASE
[[ -z $DOMAIN_BASE ]] && DOMAIN_BASE="/u01/app/oracle/admin"

echo "What will be the name of your domain? [wcc_domain]"
read DOMAIN_NAME
[[ -z $DOMAIN_NAME ]] && DOMAIN_NAME="wcc_domain"

echo "Where is your Java (JDK) Home? [/usr/java/latest]"
read JAVA_HOME
[[ -z $JAVA_HOME ]] && JAVA_HOME="/usr/java/latest"

echo "This next directory should contain all scripts, responses, and have software staged in it:"
echo "Where is the directory where you extracted this package? [$PWD]"
read MEDIA_BASE
[[ -z $MEDIA_BASE ]] && MEDIA_BASE=$PWD

PASSWORDS_MATCH=0
while [[ $PASSWORDS_MATCH == 0 ]]; do
	echo "What will be your admin (weblogic) password for the domain? [welcome1]"
	read -s ADMIN_PW
	if [[ -z $ADMIN_PW ]]; then 
		ADMIN_PW="welcome1"
		PASSWORDS_MATCH=1
	else
		echo "Confirm:"
		read -s CONF_PASS
		if [[ $ADMIN_PW == $CONF_PASS ]]; then
			PASSWORDS_MATCH=1
		else
			echo "Passwords do not match!"
			echo
		fi
	fi
done
echo

echo "Select a start mode for the domain:"
select START_MODE in dev prod; do
        echo "Mode '$START_MODE' has been selected"
        echo
        break
done

# Instance Variables
#echo "What is the hostname where your AdminServer will run? [$(hostname)]"
#read ADMIN_SERVER_HOST
echo ">> Using this host for AdminServer: $(hostname)"
echo
[[ -z $ADMIN_SERVER_HOST ]] && ADMIN_SERVER_HOST=$(hostname)
sleep 1

echo "Enter the load balancer or front-end HTTP address [$ADMIN_SERVER_HOST]"
read LOAD_BAL_ADDR
[[ -z $LOAD_BAL_ADDR ]] && LOAD_BAL_ADDR=$ADMIN_SERVER_HOST

echo "What will be the name of your WebTier instance? [ohs_instance1]"
read OHS_INSTANCE_NAME
[[ -z $OHS_INSTANCE_NAME ]] && OHS_INSTANCE_NAME="ohs_instance1"

echo "What will be the name of your OHS component? [ohs1]"
read OHS_NAME
[[ -z $OHS_NAME ]] && OHS_NAME="ohs1"

echo "On which port will your NodeManager(s) run? [5556]"
read NM_PORT
[[ -z $NM_PORT ]] && NM_PORT=5556

# DB Variables
echo "What is the JDBC URL for your database? [jdbc:oracle:thin:@$(hostname):1521/XE]"
read DB_URL
[[ -z $DB_URL ]] && DB_URL="jdbc:oracle:thin:@$(hostname):1521/XE"

echo "What is the prefix we should use to create database schemas? [DEV]"
read SCHEMA_PREFIX
[[ -z $SCHEMA_PREFIX ]] && SCHEMA_PREFIX="DEV"

echo "< Backing up old file"
cp $MEDIA_BASE/scripts/setScriptEnv.sh $MEDIA_BASE/scripts/setScriptEnv.sh-BAK 
echo "> Writing responses to file: $MEDIA_BASE/scripts/setScriptEnv.sh"
# WRITE TO FILE
sed -i "s|FMW_HOME=.*|FMW_HOME=$FMW_HOME|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|DOMAIN_BASE=.*|DOMAIN_BASE=$DOMAIN_BASE|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|DOMAIN_NAME=.*|DOMAIN_NAME=$DOMAIN_NAME|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|JAVA_HOME=.*|JAVA_HOME=$JAVA_HOME|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|MEDIA_BASE=.*|MEDIA_BASE=$MEDIA_BASE|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|ADMIN_SERVER_HOST=.*|ADMIN_SERVER_HOST=$ADMIN_SERVER_HOST|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|LOAD_BAL_ADDR=.*|LOAD_BAL_ADDR=$LOAD_BAL_ADDR|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|OHS_INSTANCE_NAME=.*|OHS_INSTANCE_NAME=$OHS_INSTANCE_NAME|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|OHS_NAME=.*|OHS_NAME=$OHS_NAME|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|NM_PORT=.*|NM_PORT=$NM_PORT|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|DB_URL=.*|DB_URL=$DB_URL|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|SCHEMA_PREFIX=.*|SCHEMA_PREFIX=$SCHEMA_PREFIX|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|ADMIN_PW=.*|ADMIN_PW=$ADMIN_PW|g" $MEDIA_BASE/scripts/setScriptEnv.sh

# DB Passwords
echo
echo "##################"
echo "OK, now I need some passwords for your database (sounds scary, right?)"
echo
PASSWORDS_MATCH=0
while [[ $PASSWORDS_MATCH == 0 ]]; do
	echo "What is the password for your sys (sysdba) user? I need it to connect to $DB_URL"
	read -s SYS_PW
	count=0
	while [[ -z $SYS_PW ]]; do
		echo "I'm not joking, I really need it to continue. Enter it now:"
		read -s SYS_PW
		let count=count+1
		[[ $count -eq 3 ]] && echo "Giving up" && exit 2
	done
	echo "Confirm:"
	read -s CONF_PASS
	if [[ $SYS_PW == $CONF_PASS ]]; then
		PASSWORDS_MATCH=1
	else
		echo "Passwords do not match!"
		echo
	fi
done

echo
PASSWORDS_MATCH=0
while [[ $PASSWORDS_MATCH == 0 ]]; do
	echo "What will be the password for your product schemas? (Sorry, they all have to be the same right now...)"
	read -s SCHEMA_PW
	count=0
	while [[ -z $SCHEMA_PW ]]; do
		echo "I'm not joking, I really need it to continue. Enter it now:"
		read -s SCHEMA_PW
		let count=count+1
		[[ $count -eq 3 ]] && echo "Giving up" && exit 2
	done
	echo "Confirm:"
	read -s CONF_PASS
	if [[ $SCHEMA_PW == $CONF_PASS ]]; then
		PASSWORDS_MATCH=1
	else
		echo "Passwords do not match!"
		echo
	fi
done

# Write new passwords file
echo "< Backing up old file"
cp $MEDIA_BASE/responses/db_schema_passwords.txt $MEDIA_BASE/responses/db_schema_passwords.txt-BAK
echo "> Writing passwords to file: $MEDIA_BASE/responses/db_schema_passwords.txt"
echo $SYS_PW > $MEDIA_BASE/responses/db_schema_passwords.txt
for i in `seq 1 7`;
do
	echo $SCHEMA_PW >> $MEDIA_BASE/responses/db_schema_passwords.txt
done

# Domain-creation script information
echo
echo "##################"
echo "Now I need some information about your domain"
echo
echo "How many UNIX machines will host resources in your domain? [1]"
read NUM_MACHINES
[[ -z $NUM_MACHINES ]] && NUM_MACHINES=1
for j in `seq 1 $NUM_MACHINES`; do
		if [[ j -eq 1 ]]; then
			echo
			echo ">> Using this machine as our first node"
			echo
			NEW_MACHINE=$(hostname)
			sleep 1
		else
			echo "Enter a resolvable hostname for machine $j:"
			read NEW_MACHINE
				count=0
				while [[ -z $NEW_MACHINE ]]; do
					echo "I'm not joking, I really need it to continue. Enter it now:"
				read NEW_MACHINE
				let count=count+1
				[[ $count -eq 3 ]] && echo "Giving up" && exit 2
			done
		fi
		MACHINE_LIST[$j]=$NEW_MACHINE
done
MACHINE_ADDRESSES="["
for k in `seq 1 $NUM_MACHINES`; do
        MACHINE_ADDRESSES="$MACHINE_ADDRESSES'${MACHINE_LIST[$k]}'"
        if [[ $k < $NUM_MACHINES ]]; then
                MACHINE_ADDRESSES="$MACHINE_ADDRESSES,"
        fi
done
MACHINE_ADDRESSES="$MACHINE_ADDRESSES]"

echo
echo "Now we need to match the servers to be deployed to the UNIX machine(s)"
echo
MACHINE_ASSIGNMENTS="dict("
NEW_SERVER_NAMES="dict("
SERVER_LIST="dict("
if [[ $NUM_MACHINES -gt 1 ]]; then
	MANAGED_SERVERS=(FMW_UCM1 FMW_UCM2 FMW_IBR1 FMW_IBR2 FMW_URM1 FMW_URM2 FMW_CAP1 FMW_CAP2 FMW_IPM1 FMW_IPM2 FMW_SOA1 FMW_SOA2 FMW_WSMPM1 FMW_WSMPM2)
else
	MANAGED_SERVERS=(FMW_UCM1 FMW_IBR1 FMW_URM1 FMW_CAP1 FMW_IPM1 FMW_SOA1 FMW_WSMPM1)
fi
for SERVER in ${MANAGED_SERVERS[*]}; do
	if [[ NUM_MACHINES -eq 1 ]]; then
		echo ">> Auto-assigning $SERVER machines to this node (${MACHINE_LIST[1]})"
		MACHINE=${MACHINE_LIST[1]}
		MACHINE_ASSIGNMENTS="$MACHINE_ASSIGNMENTS$SERVER='$MACHINE'"
		sleep 1
	else
	echo "Select a UNIX machine to host $SERVER"
		select MACHINE in ${MACHINE_LIST[*]}; do
			MACHINE_ASSIGNMENTS="$MACHINE_ASSIGNMENTS$SERVER='$MACHINE'"
			#[[ $SERVER == "FMW_UCM1" ]] && UCM_HOST=$MACHINE
			break
		done
	fi
	case "$SERVER" in
		*"UCM"*) [[ -n $UCMHOSTS ]] && UCMHOSTS=$UCMHOSTS,$MACHINE:16200
				 [[ -z $UCMHOSTS ]] && UCMHOSTS=$MACHINE:16200
				 UCMCOUNT=$(($UCMCOUNT+1))
				 ORIG_NAME="UCM_server$UCMCOUNT"
				 NEW_SERVER_NAMES="$NEW_SERVER_NAMES$ORIG_NAME='$SERVER'"
				 [[ -n $UCMCLUS ]] && UCMCLUS="$UCMCLUS,$SERVER"
				 [[ -z $UCMCLUS ]] && UCMCLUS="$SERVER"
				 SERVER_LIST="$SERVER_LIST$SERVER=16200"
				 ;;
		*"SOA"*) [[ -n $SOA_HOSTNAMES ]]&& SOA_HOSTNAMES=$SOA_HOSTNAMES,$MACHINE
				 [[ -z $SOA_HOSTNAMES ]] && SOA_HOSTNAMES=$MACHINE 
				 [[ -n $SOAHOSTS ]] && SOAHOSTS=$SOAHOSTS,$MACHINE:8001
				 [[ -z $SOAHOSTS ]] && SOAHOSTS=$MACHINE:8001
				 SOACOUNT=$(($SOACOUNT+1))
				 ORIG_NAME="soa_server$SOACOUNT"
				 NEW_SERVER_NAMES="$NEW_SERVER_NAMES$ORIG_NAME='$SERVER'"
				 [[ -n $SOACLUS ]] && SOACLUS="$SOACLUS,$SERVER"
				 [[ -z $SOACLUS ]] && SOACLUS="$SERVER"
				 SERVER_LIST="$SERVER_LIST$SERVER=8001"
				 ;;
		*"IBR"*) [[ -n $IBRHOSTS ]] && IBRHOSTS=$IBRHOSTS,$MACHINE:16250
				 [[ -z $IBRHOSTS ]] && IBRHOSTS=$MACHINE:16250
				 IBRCOUNT=$(($IBRCOUNT+1))
				 ORIG_NAME="IBR_server$IBRCOUNT"
				 NEW_SERVER_NAMES="$NEW_SERVER_NAMES$ORIG_NAME='$SERVER'"
				 SERVER_LIST="$SERVER_LIST$SERVER=16250"
				 ;;
		*"URM"*) [[ -n $URMHOSTS ]] && URMHOSTS=$URMHOSTS,$MACHINE:16300
				 [[ -z $URMHOSTS ]] && URMHOSTS=$MACHINE:16300
				 URMCOUNT=$(($URMCOUNT+1))
				 ORIG_NAME="URM_server$URMCOUNT"
				 NEW_SERVER_NAMES="$NEW_SERVER_NAMES$ORIG_NAME='$SERVER'"
				 [[ -n $URMCLUS ]] && URMCLUS="$URMCLUS,$SERVER"
				 [[ -z $URMCLUS ]] && URMCLUS="$SERVER"
				 SERVER_LIST="$SERVER_LIST$SERVER=16300"
				 ;;
		*"CAP"*) [[ -n $CAPHOSTS ]] && CAPHOSTS=$CAPHOSTS,$MACHINE:16400
				 [[ -z $CAPHOSTS ]] && CAPHOSTS=$MACHINE:16400
				 CAPCOUNT=$(($CAPCOUNT+1))
				 ORIG_NAME="capture_server$CAPCOUNT"
				 NEW_SERVER_NAMES="$NEW_SERVER_NAMES$ORIG_NAME='$SERVER'"
				 [[ -n $CAPCLUS ]] && CAPCLUS="$CAPCLUS,$SERVER"
				 [[ -z $CAPCLUS ]] && CAPCLUS="$SERVER"
				 SERVER_LIST="$SERVER_LIST$SERVER=16400"
				 ;;
		*"IPM"*) [[ -n $IPMHOSTS ]] && IPMHOSTS=$IPMHOSTS,$MACHINE:16000
				 [[ -z $IPMHOSTS ]] && IPMHOSTS=$MACHINE:16000
				 IPMCOUNT=$(($IPMCOUNT+1))
				 ORIG_NAME="IPM_server$IPMCOUNT"
				 NEW_SERVER_NAMES="$NEW_SERVER_NAMES$ORIG_NAME='$SERVER'"
				 [[ -n $IPMCLUS ]] && IPMCLUS="$IPMCLUS,$SERVER"
				 [[ -z $IPMCLUS ]] && IPMCLUS="$SERVER"
				 SERVER_LIST="$SERVER_LIST$SERVER=16000"
				 ;;
		*"WSMPM"*) [[ -n $WSMHOSTS ]] && WSMHOSTS=$WSMHOSTS,$MACHINE:7010
				[[ -z $WSMHOSTS ]] && WSMHOSTS=$MACHINE:7010
				 WSMCOUNT=$(($WSMCOUNT+1))
				 ORIG_NAME="WSM_server$WSMCOUNT"
				 #NEW_SERVER_NAMES="$NEW_SERVER_NAMES$ORIG_NAME='$SERVER'"
				 [[ -n $WSMCLUS ]] && WSMCLUS="$WSMCLUS,$SERVER"
				 [[ -z $WSMCLUS ]] && WSMCLUS="$SERVER"
				 SERVER_LIST="$SERVER_LIST$SERVER=7010"
				 ;;
	esac
	# If we're not at the end of the managed servers list, add a comma between entries
if [[ $SERVER != ${MANAGED_SERVERS[${#MANAGED_SERVERS[@]} - 1]} ]]; then
		MACHINE_ASSIGNMENTS="$MACHINE_ASSIGNMENTS, "
		SERVER_LIST="$SERVER_LIST, "
		if  [[ $SERVER != *"WSMPM"* ]]; then
			NEW_SERVER_NAMES="$NEW_SERVER_NAMES, "
		fi
	fi
done
MACHINE_ASSIGNMENTS="$MACHINE_ASSIGNMENTS)"
NEW_SERVER_NAMES="$NEW_SERVER_NAMES)"
SERVER_LIST="$SERVER_LIST)"

CLUSTER_MEMBERSHIP="dict(UCM_Cluster='$UCMCLUS', URM_Cluster='$URMCLUS', IPM_Cluster='$IPMCLUS', CAP_Cluster='$CAPCLUS', SOA_Cluster='$SOACLUS', WSMPM_Cluster='$WSMCLUS')"

echo
echo "< Backing up old file"
cp $MEDIA_BASE/responses/domain_create.py $MEDIA_BASE/responses/domain_create.py-BAK 
echo "> Writing responses to file: $MEDIA_BASE/responses/domain_create.py"
# WRITE TO FILE
sed -i "s|machine_listen_addresses =.*|machine_listen_addresses = $MACHINE_ADDRESSES|g" $MEDIA_BASE/responses/domain_create.py
sed -i "s|machine_assignments =.*|machine_assignments = $MACHINE_ASSIGNMENTS|g" $MEDIA_BASE/responses/domain_create.py
sed -i "s|new_server_names =.*|new_server_names = $NEW_SERVER_NAMES|g" $MEDIA_BASE/responses/domain_create.py
sed -i "s|server_list =.*|server_list = $SERVER_LIST|g" $MEDIA_BASE/responses/domain_create.py
sed -i "s|cluster_assignments =.*|cluster_assignments = $CLUSTER_MEMBERSHIP|g" $MEDIA_BASE/responses/domain_create.py
sed -i "s|db_pw =.*|db_pw = '$SCHEMA_PW'|g" $MEDIA_BASE/responses/domain_create.py
#sed -i "s|UCM_HOST=.*|UCM_HOST=$UCM_HOST|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|SOA_HOSTNAMES=.*|SOA_HOSTNAMES=$SOA_HOSTNAMES|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|start_mode =.*|start_mode = '$START_MODE'|g" $MEDIA_BASE/responses/domain_create.py

echo "> Writing responses to file: $MEDIA_BASE/scripts/setScriptEnv.sh"
if [[ $NUM_MACHINES -eq 1 ]]; then
	sed -i "s|MULTINODE=.*|MULTINODE=0|g" $MEDIA_BASE/scripts/setScriptEnv.sh
elif [[ $NUM_MACHINES -gt 1 ]]; then
	sed -i "s|MULTINODE=.*|MULTINODE=1|g" $MEDIA_BASE/scripts/setScriptEnv.sh
fi
sed -i "s|MACHINE_LIST=.*|MACHINE_LIST='${MACHINE_LIST[*]}'|g" $MEDIA_BASE/scripts/setScriptEnv.sh

sed -i "s|UCMHOSTS=.*|UCMHOSTS=$UCMHOSTS|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|IBRHOSTS=.*|IBRHOSTS=$IBRHOSTS|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|SOAHOSTS=.*|SOAHOSTS=$SOAHOSTS|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|URMHOSTS=.*|URMHOSTS=$URMHOSTS|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|IPMHOSTS=.*|IPMHOSTS=$IPMHOSTS|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|CAPHOSTS=.*|CAPHOSTS=$CAPHOSTS|g" $MEDIA_BASE/scripts/setScriptEnv.sh
sed -i "s|WSMHOSTS=.*|CAPHOSTS=$WSMHOSTS|g" $MEDIA_BASE/scripts/setScriptEnv.sh

WT_INSTANCE_HOME=$DOMAIN_BASE/$OHS_INSTANCE_NAME
ECM_HOME=$FMW_HOME/Oracle_ECM1
SOA_HOME=$FMW_HOME/Oracle_SOA1
WT_HOME=$FMW_HOME/Oracle_WT1

echo "> Writing OHS response and configuration files based on input."
sed -i "s|.*BEAHOME.*|       \<data-value name=\"BEAHOME\" value=\"$FMW_HOME\" \/\>|g" responses/wls_silent.xml
sed -i "s|.*WLS_INSTALL_DIR.*|       \<data-value name=\"WLS_INSTALL_DIR\" value=\"$FMW_HOME\/wlserver_10.3\" \/\>|g" responses/wls_silent.xml
sed -i "s|.*OCM_INSTALL_DIR.*|       \<data-value name=\"OCM_INSTALL_DIR\" value=\"$FMW_HOME\/coherence_3.7\" \/\>|g" responses/wls_silent.xml
sed -i "s|.*LOCAL_JVMS.*|       \<data-value name=\"LOCAL_JVMS\" value=\"$JAVA_HOME\" \/\>|g" responses/wls_silent.xml
sed -i "s|MIDDLEWARE_HOME.*|MIDDLEWARE_HOME=$FMW_HOME|g" responses/*.rsp
sed -i "s|APPSERVER_HOME.*|APPSERVER_HOME=$FMW_HOME|g" responses/*.rsp
sed -i "s|ORACLE_HOME.*|ORACLE_HOME=$ECM_HOME|g" responses/install_wcc.rsp
sed -i "s|ORACLE_HOME.*|ORACLE_HOME=$SOA_HOME|g" responses/install_soa.rsp
sed -i "s|ORACLE_HOME.*|ORACLE_HOME=$WT_HOME|g" responses/install_wt.rsp
sed -i "s|INSTANCE_HOME.*|INSTANCE_HOME=$WT_INSTANCE_HOME|g" responses/config_ohs.rsp

sed -i "s|FMWDA_RUN=.*|FMWDA_RUN=true|g" $MEDIA_BASE/scripts/setScriptEnv.sh

echo
echo "Ready to go!"
echo "Run $MEDIA_BASE/scripts/fmw_deploy.sh to get started!"
