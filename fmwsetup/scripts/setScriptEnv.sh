#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Set up environment for auto-install/configure scripts

# Base variables
FMW_HOME=/u01/app/oracle/product/fmw
DOMAIN_BASE=/u01/app/oracle/admin
DOMAIN_NAME=wcc_domain
JAVA_HOME=/usr/java/latest
# Contains extracted AUTO archive (scripts, responses, etc.) and software stage
MEDIA_BASE=/tmp/fmwsetup
ADMIN_PW=welcome1
UCM_HOST=wccapp2

# Instance Variables
ADMIN_SERVER_HOST=wccapp2
OHS_INSTANCE_NAME=ohs_instance1
OHS_NAME=ohs1
NM_PORT=5556

# DB Variables
DB_URL=jdbc:oracle:thin:@bebop-db.trumble.home:1521/bebopdb
SCHEMA_PREFIX=DEV

export FMW_HOME DOMAIN_BASE DOMAIN_NAME JAVA_HOME MEDIA_BASE ADMIN_SERVER_HOST OHS_INSTANCE_NAME OHS_NAME NM_PORT DB_URL SCHEMA_PREFIX ADMIN_PW UCM_HOST

# Derived variables
# FMW
DOMAIN_HOME=$DOMAIN_BASE/$DOMAIN_NAME/aserver/$DOMAIN_NAME
MSERVER_HOME=$DOMAIN_BASE/$DOMAIN_NAME/mserver/$DOMAIN_NAME
WT_INSTANCE_HOME=$DOMAIN_BASE/$OHS_INSTANCE_NAME
ECM_HOME=$FMW_HOME/Oracle_ECM1
SOA_HOME=$FMW_HOME/Oracle_SOA1
WT_HOME=$FMW_HOME/Oracle_WT1
WL_HOME=$FMW_HOME/wlserver_10.3
LOG_DIR=$DOMAIN_BASE/oracle_logs/$DOMAIN_NAME
INTRADOC_DIR=$DOMAIN_BASE/$DOMAIN_NAME/wcc_intradoc

# STAGING
STAGE_DIR=$MEDIA_BASE/Software/Middleware
SCRIPTS_DIR=$MEDIA_BASE/scripts
RESP_DIR=$MEDIA_BASE/responses
TEMPLATE_DIR=$MEDIA_BASE/templates

export DOMAIN_HOME MSERVER_HOME WT_INSTANCE_HOME ECM_HOME WT_HOME WL_HOME STAGE_DIR SCRIPTS_DIR RESP_DIR TEMPLATE_DIR LOG_DIR INTRADOC_DIR

# Validate all environment settings
if [[ -z $FMW_HOME ]] || [[ -z $DOMAIN_BASE ]] || [[ -z $DOMAIN_NAME ]] || [[ -z $MEDIA_BASE ]]; then
	echo "[FATAL] One or more base variables missing its assignment values. Please check 'setScriptEnv.sh' to ensure that all values are set."
	echo
	exit 2
elif [[ -z $ADMIN_SERVER_HOST ]] || [[ -z $OHS_INSTANCE_NAME ]] || [[ -z $OHS_NAME ]] || [[ -z $NM_PORT ]]; then
	echo "[FATAL] One or more instance variables are missing assignment values. Please check 'setScriptEnv.sh' to ensure that all values are set."
	echo
	exit 2
elif [[ -z $DB_URL ]] || [[ -z $SCHEMA_PREFIX ]]; then
	echo "[FATAL] One or more DB variables are missing assignment values. Please check 'setScriptEnv.sh' to ensure that all values are set."
	echo
	exit 2
elif [[ ! -a $JAVA_HOME/bin/java ]]; then
	echo "[FATAL] An invalid Java Home has been specified. Please check 'setScriptEnv.sh' to ensure that a correct Java location is set."
	echo
 	echo "This message can be safely ignored if you are on Step 0"
	echo "Would you like to continue? [y/N]"
	read user_resp
	user_resp_upper=$(echo $user_resp | tr 'a-z' 'A-Z')
	if [[ -z $user_resp ]] || [[ $user_resp_upper == "N" ]]; then
		exit 2
	elif [[ $user_resp_upper == "Y" ]]; then
		echo "Ignoring invalid Java Home..."
	else
		echo "Invalid response, exiting..."
		exit 2
	fi
fi

echo "######################################"
echo "# Scripting environment has been set #"
echo "######################################"
echo
