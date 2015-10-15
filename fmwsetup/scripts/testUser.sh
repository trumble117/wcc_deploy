#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# October 14, 2015
#
# Test that oracle user and oinstall group exists, and
# that oracle has sudo privileges. If not, create a fix
# script to run as root and retry.
#
# CHANGELOG

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
[[ ! $(grep oinstall /etc/group) ]] && sudo /usr/sbin/groupadd oinstall && echo ">> Created group: oinstall"
[[ ! $(grep oinstall /etc/group) ]] && create_error ">> [FATAL] Failed to create oinstall group"
if [[ ! $(groups | grep oinstall) ]]; then
	sudo /usr/sbin/usermod -a -G oinstall oracle || create_error ">> [FATAL] Failed to add oracle to oinstall group"
	echo ">> Modified group membership for user: oracle"
	echo "WARNING: You must now log out and back in to refresh user group membership before proceeding!"
	create_error ">> Setup will now exit"
fi
echo "> The group 'oinstall' exists and user 'oracle' is a member"
