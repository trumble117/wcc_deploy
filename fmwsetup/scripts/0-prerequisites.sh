#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# March 2, 2015
#
# Configure all system prerequisites prior to software installation and configuration
#
# CHANGELOG
# 03/02/2015 - Added SOA, Updated Patch Registry

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

THIS_USER=$(whoami)
[[ $THIS_USER != "oracle" ]] && echo ">> Please run these scripts as oracle. <<" && exit 1

# Test for sudo privileges
sudo -n touch SUDOtest
if [[ ! -a SUDOtest ]]; then
	echo "User oracle does not have the sufficient privileges to SUDO on this machine."
	echo "Execute $PWD/fixSudo.sh as a root user to fix privileges before continuing."
	echo
	
	cat << EOF > fixSudo.sh
echo "oracle	ALL=(ALL)	NOPASSWD: ALL" > /etc/sudoers.d/oracle
EOF
	exit 1
fi
[[ -a SUDOtest ]] && rm -f SUDOtest
[[ -a fixSudo.sh ]] && rm -f fixSudo.sh


# Ensure required packages are installed
sudo yum clean all
sudo yum install -y $(cat $RESP_DIR/linux_required_packages.txt)

sudo mkdir -p $FMW_HOME
sudo mkdir -p $DOMAIN_BASE
sudo chown oracle:oinstall -R $DOMAIN_BASE/../../

sudo yum install -y $STAGE_DIR/jdk-7u71-linux-x64.rpm
export PATH=$PATH:$JAVA_HOME/bin

chmod a+x $STAGE_DIR/wls1036_generic.jar

echo "Unzipping installer binaries. This can take a while..."
## Stage install files
cd $STAGE_DIR
# WebCenter Content
[[ ! -d WCC ]] && mkdir WCC
unzip -qo ofm_wcc_generic_11.1.1.8.0_disk1_1of2.zip -d WCC
unzip -qo ofm_wcc_generic_11.1.1.8.0_disk1_2of2.zip -d WCC

# SOA Suite
[[ ! -d SOA ]] && mkdir SOA
unzip -qo ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip -d SOA
unzip -qo ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip -d SOA

# Web Tier
[[ ! -d WT ]] && mkdir WT
unzip -qo ofm_webtier_linux_11.1.1.7.0_64_disk1_1of1.zip -d WT

# RCU 11.1.1.8
[[ ! -d RCU_11118 ]] && mkdir RCU_11118
unzip -qo ofm_rcu_linux_11.1.1.8.0_64_disk1_1of1 -d RCU_11118

# Create central inventory
sudo ./WCC/Disk1/stage/Response/createCentralInventory.sh /u01/app/oraInventory oinstall

# Test if admin server hostname is resolvable
hostResov=$(dig $ADMIN_SERVER_HOST | grep "ANSWER SECTION:")
if [[ -n $hostResolv ]]; then
        myIP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
        sudo echo "$myIP        $ADMIN_SERVER_HOST" >> /etc/hosts
fi

#PATCH REGISTRY
#
# p19637463_1036_Generic.zip - WebLogic Server BP 10 January 2015 (12UV)
# p18423831_111170_Linux-x86-64.zip - WebTier July 2014 SPU 
# p6880880_111000_Linux-x86-64.zip - OPatch January 2015 (11.1.0.12.5)
# p20022599_111180_Generic.zip - WebCenter Content BP9 January 2015
# p19953598_111170_Generic.zip - SOA Suite BP6 January 2015
