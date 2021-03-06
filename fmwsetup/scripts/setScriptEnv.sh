#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Set up environment for auto-install/configure scripts
# CHANGELOG
# 10/14/2015 - Added check for user
# 02/19/2016 - Added file consistency checks
#			   Updated to January 2016 patches

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
declare -A INSTALLER_SUMS
declare -A PATCH_SUMS

INSTALLER_LIST[WebCenter_Content_Disk1]="ofm_wcc_generic_11.1.1.9.0_disk1_1of2.zip"
INSTALLER_LIST[WebCenter_Content_Disk2]="ofm_wcc_generic_11.1.1.9.0_disk1_2of2.zip"
INSTALLER_LIST[Oracle_SOA_Suite_Disk1]="ofm_soa_generic_11.1.1.9.0_disk1_1of2.zip"
INSTALLER_LIST[Oracle_SOA_Suite_Disk2]="ofm_soa_generic_11.1.1.9.0_disk1_2of2.zip"
INSTALLER_LIST[Oracle_WebTier]="ofm_webtier_linux_11.1.1.9.0_64_disk1_1of1.zip"
INSTALLER_LIST[Oracle_RCU]="ofm_rcu_linux_11.1.1.9.0_64_disk1_1of1.zip"
INSTALLER_LIST[Oracle_WebLogic_Server]="wls1036_generic.jar"
INSTALLER_LIST[Java_JDK]="jdk-7u101-linux-x64.rpm"

# SHA1 Checksums
INSTALLER_SUMS[WebCenter_Content_Disk1]="116f614b6b920edfd1ff176af109a7be67b58634"
INSTALLER_SUMS[WebCenter_Content_Disk2]="e35237c375ffe97d6f4488b9170719d8f565a5c0"
INSTALLER_SUMS[Oracle_SOA_Suite_Disk1]="d9fb207815636847ab589926c85f7d0cc88a9dce"
INSTALLER_SUMS[Oracle_SOA_Suite_Disk2]="a35488a0dd4144c9adefa98264afa3307dc403eb"
INSTALLER_SUMS[Oracle_WebTier]="62442cfcea3d5e9730723ba364511849e6b07650"
INSTALLER_SUMS[Oracle_RCU]="73f34f09d8939924ef6ed926204dda6dfcb5ebcf"
INSTALLER_SUMS[Oracle_WebLogic_Server]="ffbc529d598ee4bcd1e8104191c22f1c237b4a3e"
INSTALLER_SUMS[Java_JDK]="4b2097ea1a938197137f95ff06c809730c6a7373"

PATCH_LIST[WebCenter_Content]="p22449847_111190_Generic.zip"
PATCH_LIST[Oracle_SOA_Suite]="p22469374_111190_Generic.zip"
PATCH_LIST[Oracle_WebLogic_Server]="p23094342_1036_Generic.zip"
PATCH_LIST[Oracle_OPatch]="p6880880_111000_Linux-x86-64.zip"
PATCH_LIST[Oracle_WebTier]="p23623015_111190_Linux-x86-64.zip"

# Required - Patch ID from README in WLS patch ZIP
WLS_PATCH_ID=UIAL

# SHA1 Checksums
PATCH_SUMS[WebCenter_Content]="6d112d8815bcbd39ffdda8850e3b98397a2bf61f"
PATCH_SUMS[Oracle_SOA_Suite]="f9d1bb07c33ac8c4b868ad5d99c597e6db346256"
PATCH_SUMS[Oracle_WebLogic_Server]="3c272ee7a21364100b886f0d27c74f84b58b377c"
PATCH_SUMS[Oracle_OPatch]="5f29007f3e4542ca7755ae9fa0942170b6ced170"
PATCH_SUMS[Oracle_WebTier]="b10e3a5b298ff543c4af7b9a74edc73943a62c40"

FMWDA_RUN=false

export INSTALLER_LIST PATCH_LIST WLS_PATCH_ID

echo "######################################"
echo "# Scripting environment has been set #"
echo "######################################"
echo
