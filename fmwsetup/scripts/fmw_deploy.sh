#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# Master deploy and control script
# TODO: Add step tracking
#		+ "Next" option
#		Add batching
#		+ "All" option
# CHANGELOG
# 06/17/2015 - Added WSMPM resources (separated from SOA,
#			   per documentation recommendation).

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $MY_DIR

# Source environment settings, exit on error
#[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
#[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

usage(){
	echo "Usage:  	./fmw_deploy.sh {function} {step}"
	echo
	echo "Functions:	-d		Deploy/install this step"
	echo "		-u		Revert/uninstall this step"
	echo "		-h|-help	Launch this message"
	echo
	echo "Steps:		 0	-	Establish node equivalence"
	echo "		 1	-	Perform prerequisites"
	echo "		 2	-	Install WebLogic Server"
	echo "		 3	-	Install WebCenter Content"
	echo "		 4	-	Install Web Tier"
	echo " 		 5	-	Install SOA Suite"
	echo "		 6	-	Apply FMW oneoff patches"
	echo "		 7	-	Create FMW DB schemas"
	echo "		 8	-	Create WebLogic domain"
	echo "		 9	-	Install wls helper scripts"
	echo "		 10	-	Perform post-domain-config operations"
	echo "		 11	-	Configure Web Tier"
	echo "		 12	-	Install OHS configuration"
	echo "		 13	-	Install initial configuration for WCC + IBR"
}

[[ -z $1 ]] && usage && exit 2

# Convert upper to lower cases
FUNC=$(echo $1 | tr 'A-Z' 'a-z')
STEP=$2

if [[ $FUNC == "-h" ]] || [[ $FUNC == "-help" ]]; then
	usage
	exit
elif [[ $FUNC == "-d" ]]; then
	case $STEP in
	0) ./0-ssh_equivalence_setup.sh;;
	1) ./01-run_prerequisites.sh;;
	2) ./02-wls_silent_install.sh;;
	3) ./03-wcc_silent_install.sh;;
	4) ./04-wt_silent_install.sh;;
	5) ./05-soa_silent_install.sh;;
	6) ./06-fmw_patch.sh;;
	7) ./07-create_db_schemas.sh;;
	8) ./08-create_domain.sh;;
	9) ./09-deploy_start_scripts.sh;;
	10) ./10-post_domain_config.sh;;
	11) ./11-webtier_config.sh;;
	12) ./12-ohs_setup.sh;;
	13) ./13-wcc_config.sh;;
	*) echo "Not a valid step: $STEP"
	   usage
	   exit 2;;
	esac
elif [[ $FUNC == "-u" ]]; then
	case $STEP in
	1|2|3|4|5|6|7|8) ./0$STEP-undo.sh;;
	11|12|13) ./$STEP-undo.sh;;
	0|9|10) echo "No undo option available for this step";;
	*) echo "Not a valid step: $STEP"
	   usage
	   exit 2;;
	esac
else
	echo "$FUNC is not a valid function"
	usage
	exit 2
fi
