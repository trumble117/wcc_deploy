# Oracle WebCenter Content Deployment Assistant [BETA]

## Description
This script set deploys the Oracle WebCenter Content Suite according to the 11.1.1.8 Enterprise Deployment Guide. The deployment is done via command line without the need for a GUI. Though it should be noted that several products contained in this suite still rely upon X libraries to function correctly. Multi-node deployment is now fully supported, though testing has been rather limited.

## Restrictions
There are some limitations or restrictions applicable to the current release that you should be aware of prior to beginning:

* You must obtain all software and patches on your own. The installation binaries are both proprietary, and quite large, and therefore I cannot ship them with these scripts. For a list of required software archives, see the section on **Software**.
* Prior to beginning the deployment, ensure the the user *oracle* exists, and is a member of the group *oinstall*. This user need also have password-free sudo rights for the purposes of deployment. If these prerequisites are not met, the installer will stop and provide a fix script that must be run as *root* to continue.
	* These scripts must also be run as *oracle*. The scripts should do a check for these things and offer solutions, but it's easier to have them taken care of before beginning.
* These scripts will perform an installation, and some basic configuration only. No other higher-level or user-specific configuration is performed.

## Support
These scripts have only been tested on Oracle Enterprise Linux 6.6 and 6.7 with a 64-bit architecture. It is likely that they will work on any RHEL6-based OS, but that has not been proven. Any other Linux variant is not guaranteed compatible. Debian-based systems would definitely have some issues.

## Software
This section describes the required software packages to be downloaded and staged prior to starting. Installation binaries can be found on OTN and patches can be found in MOS.

The following base installation packages will need to be present in the {SCRIPT_HOME}/Software/Middleware directory. See the section on **Directory Structure** for a more detailed explanation. Note that this includes WLS and JDK installers.

| Product | Version | Archive Name |
| ------- | ------- | ------------ |
| WebCenter Content | 11.1.1.8 | ofm_wcc_generic_11.1.1.8.0_disk1_1of2.zip |
|                   |          | ofm_wcc_generic_11.1.1.8.0_disk1_2of2.zip |
| Oracle SOA Suite | 11.1.1.7 | ofm_soa_generic_11.1.1.7.0_disk1_1of2.zip |
|            |          | ofm_soa_generic_11.1.1.7.0_disk1_2of2.zip |
| Oracle WebTier | 11.1.1.9 | ofm_webtier_linux_11.1.1.9.0_64_disk1_1of1.zip |
| Oracle RCU | 11.1.1.8 | ofm_rcu_linux_11.1.1.8.0_64_disk1_1of1.zip |
| Oracle WebLogic Server | 10.3.6 | wls1036_generic.jar |
| Oracle JDK |	1.8.0 Update 60	|	jdk-8u60-linux-x64.rpm	|

The following patches will need to be present in a PATCHES directory underneath the Middleware directory containing the binary installers.

| Product | Archive Name | Release |
| ------- | ------------ | ------------ |
| WebCenter Content | p21631736_111190_Generic.zip | Bundle Patch 3 (September 2015) |
| Oracle SOA Suite | p20900797_111170_Generic.zip | Bundle Patch 8 (July 2015) |
| Oracle WebLogic Server | p20780171_1036_Generic.zip | EJUW (July 2015) |
| Oracle OPatch | p6880880_111000_Linux-x86-64.zip | 11.1.0.12.7 (July 2015) |

#### NOTE: The location of these files is very important. They must have the above names and be in the proper location, else deployment will fail and will not continue.

## Directory Structure
You can stage the scripts/software from anywhere you like, as long as **oracle** has access to it. Do keep in mind, though, that we will be extracting zip archives and running installers, so while NFS locations are supported, performance may be affected. Once you've chosen a base directory for your scripts (I like to use /tmp), make sure that all of the following are present:

```
--- BASE_DIR
	\--- fmwsetup
		\--- responses
			\--- (all response files)
		\--- scripts
			\--- (deployment scripts)
			\--- output
				\--- (output logs from product installs - should be empty)
		\--- templates
			\--- (templates - should be empty)
		\--- Software
			\--- Middleware
				\--- (all product installation archives)
				\--- PATCHES
					\--- (all product patches)
```

## Deployment Instructions
#### Prerequisite - An Oracle database must be installed and accessible to complete deployment. You must also know the password for the sys user. These scripts will not do that for you; they will only create the necessary users and schemas for the products being deployed. If you already have an external database available, great. If not, I like to use an XE instance running in a Docker container (https://github.com/trumble117/oracle_xe). If you are unfamiliar with Docker, it may be wise to simply install Oracle XE on the same machine. Do note, though, that I have not tested that deployment, and installation locations may interfere with one another if you use the defaults. Just beware.

The scripts were made with simplicity in mind. You will use a utility to answer a few questions to customize the deployment, then use a deployment script to step through it.

1. Download these scripts and place them in a base directory
2. Download product installers and patches and place them in their appropriate directories under the base directory (described in above sections)
3. From BASH, **as oracle**, navigate to the *fmwsetup* directory, and run *fmwda.sh*
	- *Example: ./fmwda.sh*
	- Answer the questions it asks, as you are setting the values for your deployment.
4. From BASH, **as oracle**, use *scripts/fmw_deploy.sh* to step through your deployment. Running it sans arguments will display the help function, along with descriptions for each step.
	- *Example (to deploy step 0): ./scripts/fmw_deploy.sh -d 0*
	- Most steps have an undo function that will allow you to back up in case the step fails and you need to retry
5. During a few of the steps (product installations - steps 3, 4, and 5), the installation gets forked to a background process, and the output does not go to standard out. A log file is displayed for you to follow the installation progress. The spinner will stop when the background process is done, but it is still recommended to inspect the log for errors. *It is possible that no indication will be made that an error has occurred.*
6. After all of the steps have been completed, the AdminServer, Nodemanager, and OHS instance will be up and running. None of the managed servers will be started, however. Navigate to the WLS Administration Console to get started:
	- http://your_hostname:7001/console
7. On future start-ups, these resources will not auto-start. I install a small utility to help ease the process, however. It is available as the 'wls' command from BASH, and can be used to start the AdminServer and NodeManager. Run 'wls' (after a profile refresh) to display usage information.
	- OHS, on the other hand, is controlled via **opmnctl**, located at {DOMAIN_BASE}/{OHS_INSTANCE_NAME}/bin/opmnctl

Please submit issues to me via GitHub. Any time I make a major modification, I always step through a full deployment. However, everyone's setup is different and may run into different issues than me. This is a beta release, and should be treated as such. I offer no warranties or guarantees in conjunction with this code.