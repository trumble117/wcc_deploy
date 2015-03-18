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

MY_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $MY_DIR

# Source environment settings, exit on error
#[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . setScriptEnv.sh
#[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

usage(){
	echo "Usage:  	./fmw_deploy.sh {function} {step}"
	echo
	echo "Functions:	-d		Deploy/install this step"
	echo "		-u		Revert/uninstall this step"
	echo "		-h|-help	Launch this message"
	echo
	echo "Steps:		 0	-	Run prerequisites"
	echo "		 1	-	Install WebLogic Server"
	echo "		 2	-	Install WebCenter Content"
	echo "		 3	-	Install Web Tier"
	echo " 		 4	-	Install SOA Suite"
	echo "		 5	-	Apply FMW oneoff patches"
	echo "		 6	-	Create FMW DB schemas"
	echo "		 7	-	Create WebLogic domain"
	echo "		 8	-	Install wls helper scripts"
	echo "		 9	-	Perform post-domain-config operations"
	echo "		10	-	Configure Web Tier"
	echo "		11	-	Install OHS configuration"
	echo "		12	-	Install initial configuration for WCC + IBR"
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
	0) ./0-prerequisites.sh;;
	1) ./1-wls_silent_install.sh;;
	2) ./2-wcc_silent_install.sh;;
	3) ./3-wt_silent_install.sh;;
	4) ./4-soa_silent_install.sh;;
	5) ./5-fmw_patch.sh;;
	6) ./6-create_db_schemas.sh;;
	7) ./7-create_domain.sh;;
	8) ./8-start_script_setup.sh;;
	9) ./9-post_domain_config.sh;;
	10) ./10-webtier_config.sh;;
	11) ./11-ohs_setup.sh;;
	12) ./12-wcc_config.sh;;
	*) echo "Not a valid step: $STEP"
	   usage
	   exit 2;;
	esac
elif [[ $FUNC == "-u" ]]; then
	case $STEP in
	0|1|2|3|4|5|6|7|10|11|12) ./$STEP-undo.sh;;
	8|9) echo "No undo option available for this step";;
	*) echo "Not a valid step: $STEP"
	   usage
	   exit 2;;
	esac
else
	echo "$FUNC is not a valid function"
	usage
	exit 2
fi
