#!/bin/bash
#
# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

echo "> Beginning WLS Silent Installation"
echo ">> Silent XML: $RESP_DIR/wls_silent.xml"
echo

$JAVA_HOME/bin/java -Xmx1024m -jar $STAGE_DIR/wls1036_generic.jar -mode=silent -silent_xml=$RESP_DIR/wls_silent.xml

# Copy required jars to Java Home
[[ ! -d $JAVA_HOME/jre/lib/endorsed ]] && sudo mkdir $JAVA_HOME/jre/lib/endorsed
sudo cp $FMW_HOME/modules/javax.annotation_1.0.0.0_1-0.jar $JAVA_HOME/jre/lib/endorsed/
sudo cp $FMW_HOME/modules/javax.xml.bind_2.1.1.jar $JAVA_HOME/jre/lib/endorsed/
sudo cp $FMW_HOME/modules/javax.xml.ws_2.1.1.jar $JAVA_HOME/jre/lib/endorsed/

RETVAL=$?
if [[ $RETVAL -eq 0 ]]; then
	echo "WebLogic was installed successfully!"
elif [[ $RETVAL -eq 1 ]]; then
	echo "[FATAL] Installation failed due to fatal error."
	exit 2
else
	echo "[FATAL] Installation failed due to XML parsing error."
	exit 2
fi
