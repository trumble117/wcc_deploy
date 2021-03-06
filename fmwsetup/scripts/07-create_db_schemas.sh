#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Use RCU to create necessary DB schemas
# 
# CHANGELOG
# 03/02/15 - Include SOA Suite components

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

echo "> Begin schema creation"

if [[ $IS_SYSDBA == "Y" ]]; then
	$STAGE_DIR/RCU_11119/rcuHome/bin/rcu -silent -createRepository -connectString $DB_URL -dbUser $DB_USER -dbRole sysdba -schemaPrefix $SCHEMA_PREFIX -component CONTENTSERVER11 -component URM -component CAPTURE -component MDS -component IPM -component SOAINFRA -component ORASDPM -f < $RESP_DIR/db_schema_passwords.txt
else
	$STAGE_DIR/RCU_11119/rcuHome/bin/rcu -silent -createRepository -connectString $DB_URL -dbUser $DB_USER -schemaPrefix $SCHEMA_PREFIX -component CONTENTSERVER11 -component URM -component CAPTURE -component MDS -component IPM -component SOAINFRA -component ORASDPM -f < $RESP_DIR/db_schema_passwords.txt
fi
echo "> Schema creation complete"