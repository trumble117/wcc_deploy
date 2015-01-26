#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Use RCU to create necessary DB schemas

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

echo "> Begin schema creation"

$STAGE_DIR/RCU_11118/rcuHome/bin/rcu -silent -createRepository -connectString $DB_URL -dbUser sys -dbRole sysdba -schemaPrefix $SCHEMA_PREFIX -component CONTENTSERVER11 -component URM -component CAPTURE -component MDS -component IPM -f < $RESP_DIR/db_schema_passwords.txt

echo "> Schema creation complete"