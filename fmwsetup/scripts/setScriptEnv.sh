#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Set up environment for auto-install/configure scripts
# CHANGELOG
# 10/14/2015 - Added check for user

# Base variables
FMW_HOME=/u01/app/oracle/product/fmw
DOMAIN_BASE=/u01/app/oracle/admin
DOMAIN_NAME=wcc_domain
JAVA_HOME=/usr/java/latest
JAVA_VENDOR=Sun
MULTINODE=0
MACHINE_LIST="wccapp2"
# Contains extracted AUTO archive (scripts, responses, etc.) and software stage
MEDIA_BASE=/tmp/fmwsetup
ADMIN_PW=welcome1
#UCM_HOST=wccapp2		--> Unneeded? JT 04/10/2015
SOA_HOSTNAMES=wccapp2

# Instance Variables
ADMIN_SERVER_HOST=wccapp2
LOAD_BAL_ADDR=wccapp2
OHS_INSTANCE_NAME=ohs_instance1
OHS_NAME=ohs1
NM_PORT=5556

# OHS Config Variables
UCMHOSTS=wccapp2:16200
SOAHOSTS=wccapp2:8001
IBRHOSTS=wccapp2:16250
URMHOSTS=wccapp2:16300
IPMHOSTS=wccapp2:16000
CAPHOSTS=wccapp2:16400
WSMHOSTS=wccapp2:7010

# Mail Variables
SMTP_SRV=mail
SMTP_ADM=sysadmin@example.com

# DB Variables
DB_URL=jdbc:oracle:thin:@localhost:1521/XE
SCHEMA_PREFIX=DEV
DB_USER=sys
IS_SYSDBA=Y

export FMW_HOME DOMAIN_BASE DOMAIN_NAME JAVA_HOME JAVA_VENDOR MEDIA_BASE ADMIN_SERVER_HOST OHS_INSTANCE_NAME OHS_NAME NM_PORT DB_URL SCHEMA_PREFIX ADMIN_PW SOA_HOSTNAMES LOAD_BAL_ADDR MULTINODE MACHINE_LIST
export UCMHOSTS SOAHOSTS IBRHOSTS URMHOSTS IPMHOSTS CAPHOSTS WSMHOSTS DB_USER

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

export DOMAIN_HOME MSERVER_HOME WT_INSTANCE_HOME ECM_HOME WT_HOME WL_HOME STAGE_DIR SCRIPTS_DIR RESP_DIR TEMPLATE_DIR LOG_DIR INTRADOC_DIR SOA_HOME

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
elif [[ ! -a $JAVA_HOME/bin/java ]] && [[ $IGNORE_JAVA != true ]]; then
	echo "[FATAL] An invalid Java Home has been specified. Please check 'setScriptEnv.sh' to ensure that a correct Java location is set."
	echo
 	echo "This message can be safely ignored if you have not yet completed Step 1"
	echo "Would you like to continue? [y/N]"
	read user_resp
	user_resp_upper=$(echo $user_resp | tr 'a-z' 'A-Z')
	if [[ -z $user_resp ]] || [[ $user_resp_upper == "N" ]]; then
		exit 2
	elif [[ $user_resp_upper == "Y" ]]; then
		echo "Ignoring invalid Java Home..."
		export IGNORE_JAVA=true
	else
		echo "Invalid response, exiting..."
		exit 2
	fi
fi

# Ensure we're running scripts as oracle
THIS_USER=$(whoami)
if [[ $THIS_USER != "oracle" ]]; then
	echo ">> Please run these scripts as oracle. <<"
	echo "Fatal error.. exiting."
	exit 2
fi

# Populate software package lists
declare -A INSTALLER_LIST
declare -A PATCH_LIST

INSTALLER_LIST[WebCenter_Content_Disk2]="ofm_wcc_generic_11.1.1.9.0_disk1_2of2.zip"
INSTALLER_LIST[Oracle_SOA_Suite_Disk1]="ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip"
INSTALLER_LIST[Oracle_SOA_Suite_Disk2]="ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip"
INSTALLER_LIST[Oracle_WebTier]="ofm_webtier_linux_11.1.1.9.0_64_disk1_1of1.zip"
INSTALLER_LIST[Oracle_RCU]="ofm_rcu_linux_11.1.1.9.0_64_disk1_1of1.zip"
INSTALLER_LIST[Oracle_WebLogic_Server]="wls1036_generic.jar"
INSTALLER_LIST[Java_JDK]="jdk-8u60-linux-x64.rpm"

PATCH_LIST[WebCenter_Content]="p21631736_111190_Generic.zip"
PATCH_LIST[Oracle_SOA_Suite]="p20900797_111170_Generic.zip"
PATCH_LIST[Oracle_WebLogic_Server]="p20780171_1036_Generic.zip"
PATCH_LIST[Oracle_OPatch]="p6880880_111000_Linux-x86-64.zip"

FMWDA_RUN=false

export INSTALLER_LIST PATCH_LIST

echo "######################################"
echo "# Scripting environment has been set #"
echo "######################################"
echo
