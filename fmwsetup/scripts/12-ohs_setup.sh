# Johnathon Trumble
# john.trumble@oracle.com
# March 5, 2015
#
# Create OHS proxy configuration
#
# CHANGELOG
# 03/02/2015 - Updated to include Imaging and SOA

# Source environment settings, exit on error
[[ ! -a setScriptEnv.sh ]] && echo "[> Environment setup could not be completed. Ensure you are executing from the scripts directory, or via the fmw_deploy utility <]" && exit 2 || . ./setScriptEnv.sh
[[ $? == "2" ]] && echo "[> Halting script execution <]" && exit 2

# Has to be done here because of the way the config.sh process is launched
echo ">> Cleanup temporary files from previous step"
rm -rf /tmp/staticports.ini

# Backup existing config
cp $WT_INSTANCE_HOME/config/OHS/$OHS_NAME/mod_wl_ohs.conf $WT_INSTANCE_HOME/config/OHS/$OHS_NAME/mod_wl_ohs.conf-BAK

echo ">> Writing new configuration to $WT_INSTANCE_HOME/config/OHS/$OHS_NAME/mod_wl_ohs.conf"
# Create new
cat << EOF > $WT_INSTANCE_HOME/config/OHS/$OHS_NAME/mod_wl_ohs.conf
# NOTE : This is a template to configure mod_weblogic. 

LoadModule weblogic_module   "\${ORACLE_HOME}/ohs/modules/mod_wl_ohs.so"

# This empty block is needed to save mod_wl related configuration from EM to this file when changes are made at the Base Virtual Host Level
<IfModule weblogic_module>
#      WebLogicHost <WEBLOGIC_HOST>
#      WebLogicPort <WEBLOGIC_PORT>
#      Debug ON
#      WLLogFile /tmp/weblogic.log
#      MatchExpression *.jsp
 # Content Server
 <Location /cs>
	     SetHandler weblogic-handler
		 WebLogicCluster $UCMHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>
 <Location /adfAuthentication>
	     SetHandler weblogic-handler
		 WebLogicCluster $UCMHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>
<Location /_ocsh>
	     SetHandler weblogic-handler
		 WebLogicCluster $UCMHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>
 
 # Inbound Refinery
  <Location /ibr>
	     SetHandler weblogic-handler
		 WebLogicCluster $IBRHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>
 
 # Document Capture
 <Location /dc-client>
	     SetHandler weblogic-handler
		 WebLogicCluster $CAPHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>
  <Location /dc-console>
	     SetHandler weblogic-handler
		 WebLogicCluster $CAPHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>
  <Location /dc-help>
	     SetHandler weblogic-handler
		 WebLogicCluster $CAPHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>
 
 # URM
  <Location /urm>
	     SetHandler weblogic-handler
		 WebLogicCluster $URMHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>

 # Imaging
 <Location /imaging>
	     SetHandler weblogic-handler
		 WebLogicCluster $URMHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>
<Location /axf-ws>
	     SetHandler weblogic-handler
		 WebLogicCluster $URMHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>

 # WSM-PM
 <Location /wsm-pm>
	     SetHandler weblogic-handler
		 WebLogicCluster $SOAHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>

 # SOA soa-infra app
 <Location /soa-infra>
	     SetHandler weblogic-handler
		 WebLogicCluster $SOAHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>

 # SOA inspection.wsil
 <Location /inspection.wsil>
	     SetHandler weblogic-handler
		 WebLogicCluster $SOAHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>

 # Worklist
 <Location /integration/>
	     SetHandler weblogic-handler
		 WebLogicCluster $SOAHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>

 # UMS prefs
 <Location /sdpmessaging/userprefs-ui>
	     SetHandler weblogic-handler
		 WebLogicCluster $SOAHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>

 # Default to-do taskflow
 <Location /DefaultToDoTaskFlow/>
	     SetHandler weblogic-handler
		 WebLogicCluster $SOAHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>

# Workflow
 <Location /workflow>
	     SetHandler weblogic-handler
		 WebLogicCluster $SOAHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>

 #SOA Composer
 <Location /soa/composer>
	     SetHandler weblogic-handler
		 WebLogicCluster $SOAHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>
 
</IfModule>
EOF

# Backup existing config
cp $WT_INSTANCE_HOME/config/OHS/$OHS_NAME/ssl.conf $WT_INSTANCE_HOME/config/OHS/$OHS_NAME/ssl.conf-BAK

echo ">> Writing new configuration to $WT_INSTANCE_HOME/config/OHS/$OHS_NAME/ssl.conf"
# Create new
cat << EOF > $WT_INSTANCE_HOME/config/OHS/$OHS_NAME/ssl.conf
###################################################################
# Oracle HTTP Server mod_ossl configuration file: ssl.conf        #
###################################################################


# OHS Listen Port
Listen 443

<IfModule ossl_module>
##
##  SSL Global Context
##
##  All SSL configuration in this context applies both to
##  the main server and all SSL-enabled virtual hosts.
##

#
#   Some MIME-types for downloading Certificates and CRLs
    AddType application/x-x509-ca-cert .crt
    AddType application/x-pkcs7-crl    .crl

#   Pass Phrase Dialog:
#   Configure the pass phrase gathering process.
#   The filtering dialog program ('builtin' is a internal
#   terminal dialog) has to provide the pass phrase on stdout.
    SSLPassPhraseDialog  builtin

#   Inter-Process Session Cache:
#   Configure the SSL Session Cache: First the mechanism 
#   to use and second the expiring timeout (in seconds).
    SSLSessionCache "shmcb:\${ORACLE_INSTANCE}/diagnostics/logs/\${COMPONENT_TYPE}/\${COMPONENT_NAME}/ssl_scache(512000)"
    SSLSessionCacheTimeout  300

#   Semaphore:
#   Configure the path to the mutual exclusion semaphore the
#   SSL engine uses internally for inter-process synchronization. 
    <IfModule mpm_winnt_module>
      SSLMutex "none"
    </IfModule>
    <IfModule !mpm_winnt_module>
      SSLMutex pthread
    </IfModule>

##
## SSL Virtual Host Context
##
<VirtualHost *:443>
  <IfModule ossl_module>
   #  SSL Engine Switch:
   #  Enable/Disable SSL for this virtual host.
   SSLEngine on

   #  Client Authentication (Type):
   #  Client certificate verification type and depth.  Types are
   #  none, optional and require.
   SSLVerifyClient None

   #  SSL Protocol Support:
   #  List the supported protocols.
   SSLProtocol nzos_Version_1_0 nzos_Version_3_0

   #  SSL Cipher Suite:
   #  List the ciphers that the client is permitted to negotiate.
   SSLCipherSuite SSL_RSA_WITH_RC4_128_MD5,SSL_RSA_WITH_RC4_128_SHA,SSL_RSA_WITH_3DES_EDE_CBC_SHA,SSL_RSA_WITH_DES_CBC_SHA,TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA

   # SSL Certificate Revocation List Check
   # Valid values are On and Off
   SSLCRLCheck Off

   #Path to the wallet
   SSLWallet "\${ORACLE_INSTANCE}/config/\${COMPONENT_TYPE}/\${COMPONENT_NAME}/keystores/default"
        
   <FilesMatch "\.(cgi|shtml|phtml|php)$">
      SSLOptions +StdEnvVars
   </FilesMatch>

   <Directory "\${ORACLE_INSTANCE}/config/\${COMPONENT_TYPE}/\${COMPONENT_NAME}/cgi-bin">
      SSLOptions +StdEnvVars
   </Directory>

   BrowserMatch ".*MSIE.*" \
   nokeepalive ssl-unclean-shutdown \
   downgrade-1.0 force-response-1.0

  </IfModule>
  <IfModule weblogic_module>
#      WebLogicHost <WEBLOGIC_HOST>
#      WebLogicPort <WEBLOGIC_PORT>
#      Debug ON
#      WLLogFile /tmp/weblogic.log
#      MatchExpression *.jsp
 # Content Server
  <Location /cs>
	     SetHandler weblogic-handler
		 WebLogicCluster $UCMHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>
  <Location /adfAuthentication>
	     SetHandler weblogic-handler
		 WebLogicCluster $UCMHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>
 <Location /_ocsh>
	     SetHandler weblogic-handler
		 WebLogicCluster $UCMHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>
 
 # Inbound Refinery
  <Location /ibr>
	     SetHandler weblogic-handler
		 WebLogicCluster $IBRHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>
 
 # Document Capture
 <Location /dc-client>
	     SetHandler weblogic-handler
		 WebLogicCluster $CAPHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>
  <Location /dc-console>
	     SetHandler weblogic-handler
		 WebLogicCluster $CAPHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>
  <Location /dc-help>
	     SetHandler weblogic-handler
		 WebLogicCluster $CAPHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>
 
 # URM
  <Location /urm>
	     SetHandler weblogic-handler
		 WebLogicCluster $URMHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>

 # Imaging
 <Location /imaging>
	     SetHandler weblogic-handler
		 WebLogicCluster $URMHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>
<Location /axf-ws>
	     SetHandler weblogic-handler
		 WebLogicCluster $URMHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>

 # WSM-PM
 <Location /wsm-pm>
	     SetHandler weblogic-handler
		 WebLogicCluster $SOAHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>

 # SOA soa-infra app
 <Location /soa-infra>
	     SetHandler weblogic-handler
		 WebLogicCluster $SOAHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>

 # SOA inspection.wsil
 <Location /inspection.wsil>
	     SetHandler weblogic-handler
		 WebLogicCluster $SOAHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>

 # Worklist
 <Location /integration/>
	     SetHandler weblogic-handler
		 WebLogicCluster $SOAHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>

 # UMS prefs
 <Location /sdpmessaging/userprefs-ui>
	     SetHandler weblogic-handler
		 WebLogicCluster $SOAHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>

 # Default to-do taskflow
 <Location /DefaultToDoTaskFlow/>
	     SetHandler weblogic-handler
		 WebLogicCluster $SOAHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>

# Workflow
 <Location /workflow>
	     SetHandler weblogic-handler
		 WebLogicCluster $SOAHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>

 #SOA Composer
 <Location /soa/composer>
	     SetHandler weblogic-handler
		 WebLogicCluster $SOAHOSTS
	     WLProxySSL OFF
	     WLProxySSLPassThrough OFF
 </Location>
</IfModule>
</VirtualHost>

</IfModule>
EOF

echo ">> Fixing group in httpd.conf"
sed -i 's/#Group GROUP_TEMPLATE/Group oinstall/g' $WT_INSTANCE_HOME/config/OHS/$OHS_NAME/httpd.conf

echo ">> Configuration copied, restarting services..."

# Restart services
$WT_INSTANCE_HOME/bin/opmnctl stopall
sleep 5
$WT_INSTANCE_HOME/bin/opmnctl startall
