#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Drop DB schemas created with step 5

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

echo "> Begin drop of DB schemas"

$STAGE_DIR/RCU_11118/rcuHome/bin/rcu -silent -dropRepository -connectString $DB_URL -dbUser sys -dbRole sysdba -schemaPrefix $SCHEMA_PREFIX -component CONTENTSERVER11 -component URM -component CAPTURE -component MDS -f < ../responses/db_schema_passwords.txt

echo "> FMW schema drop complete"
