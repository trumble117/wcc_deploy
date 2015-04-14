#!/usr/bin/python
#
# Johnathon Trumble
# john.trumble@oracle.com
# March 18, 2015
#
# CHANGELOG
# 03/18/2015 - Added SOA resources
# 03/19/2015 - Added functionality to edit server names
# 			   to make them more consistent
#			   Added variable-based start mode
# 04/13/2015 - Moved all post-creation domain configuration
#              into this script
#              Added SOA tangosol configuration

import os, sys

# USER-DEFINED
ucm_cluster_name = 'UCM_Cluster' 		# Used for XDO assignment later
ipm_cluster_name = 'IPM_Cluster'
soa_cluster_name = 'SOA_Cluster'
# Comma-separate server assignments to clusters
cluster_assignments = dict(UCM_Cluster='FMW_UCM1', URM_Cluster='FMW_URM1', CAP_Cluster='FMW_CAP1', IPM_Cluster='FMW_IPM1', SOA_Cluster='FMW_SOA1')
# Create key:value pairs for servers to be created and the machine on which they will run (correspond to listen addresses)
machine_assignments = dict(FMW_UCM1='wccapp2', FMW_IBR1='wccapp2', FMW_URM1='wccapp2', FMW_CAP1='wccapp2', FMW_IPM1='wccapp2', FMW_SOA1='wccapp2')
new_server_names = dict(UCM_server1='FMW_UCM1', IBR_server1='FMW_IBR1', URM_server1='FMW_URM1', capture_server1='FMW_CAP1', IPM_server1='FMW_IPM1', soa_server1='FMW_SOA1')
machine_listen_addresses = ['wccapp2']
db_pw = 'welcome1'
start_mode = 'dev'

# Templates
ucm_template_list = ['oracle.ucm.core_template_11.1.1.jar','oracle.ucm.cs_template_11.1.1.jar','oracle.ucm.ibr_template_11.1.1.jar','oracle.ucm.urm_template_11.1.1.jar','oracle.capture_template_11.1.1.jar','oracle.ipm_template_11.1.1.jar']
soa_template_list = ['oracle.soa_template_11.1.1.jar']

# Grab environment variables
app_dir = os.getenv('DOMAIN_BASE') + '/' + os.getenv('DOMAIN_NAME') + '/aserver/applications'
java_home = os.getenv('JAVA_HOME')
nm_listen_port = os.getenv('NM_PORT')
domain_home = os.getenv('DOMAIN_HOME')
domain_name = os.getenv('DOMAIN_NAME')
ucm_templates = os.getenv('ECM_HOME') + '/common/templates/applications/'
soa_templates = os.getenv('SOA_HOME') + '/common/templates/applications/'
wls_template = os.getenv('WL_HOME') + '/common/templates/domains/wls.jar'
admin_pw = os.getenv('ADMIN_PW')
frontend_host = os.getenv('LOAD_BAL_ADDR')
# DB variables
db_url = os.getenv('DB_URL')
db_prefix = os.getenv('SCHEMA_PREFIX') + '_'

tlog_loc = os.getenv('DOMAIN_BASE') + "/" + os.getenv('DOMAIN_NAME') + "/resources/tlogs"
log_dir = os.getenv('LOG_DIR')

# DEFINITIONS
def create_machines():
	print '>>> Create machines and assign servers to them'
	servers = cmo.getServers()
	for i in range(len(machine_listen_addresses)):
		cd('/')
		split_name = machine_listen_addresses[i].split('.')
		shortname = split_name[0]
		machine = create('machine_' + machine_listen_addresses[i], 'UnixMachine')
		cd('Machine/' + machine.getName())
		create(machine.getName(), 'NodeManager')
		cd('NodeManager/' + machine.getName())
		cmo.setListenAddress(machine_listen_addresses[i])
		cmo.setNMType('SSL')
		cmo.setListenPort(int(nm_listen_port))
		print '>>> Created UNIX Machine: ' + machine.getName()
		for server in servers:
			if server.getName() == 'AdminServer':
				print '>>>> Encountered AdminServer, skipping machine assingnment'
			else:
				cur_server = machine_assignments[server.getName()]
				if cur_server == machine_listen_addresses[i]:
					print '>>>> Assigning ' + server.getName() + ' to ' + machine.getName()
					server.setMachine(machine)
	cd('/')
	machines = ls('/Machine/')
	if machines.find('LocalMachine') != -1:
		print ">>> Deleting LocalMachine"
		delete('LocalMachine','Machine')

def create_cluster(cluster_name):
    print '>>> Create cluster: ' + cluster_name
    cluster = create(cluster_name, 'Cluster')
    cluster.setClusterMessagingMode('unicast')
    cluster.setWeblogicPluginEnabled(java.lang.Boolean('true'))
    #return cluster;

def create_assign_cluster(cluster_name):
	create_cluster(cluster_name)
	print '>>>> Assigning ' + cluster_assignments[cluster_name] + ' to ' + cluster_name
	assign('Server', cluster_assignments[cluster_name], 'Cluster', cluster_name)

def configure_datasource(jdbc_name):
	print '>>> Configuring ' + jdbc_name
	cd('/JDBCSystemResource/' + jdbc_name + '/JdbcResource/' + jdbc_name + '/JDBCDriverParams/NO_NAME_0')
	cmo.setPasswordEncrypted(db_pw)
	cmo.setUrl(db_url)
	
	cd('Properties/NO_NAME_0/Property/user')
	curValue = cmo.getValue()
	newValue = curValue.replace('DEV_', db_prefix)
	cmo.setValue(newValue)

def update_server_name(old_name, new_name):
	print '>>> Changing ' + old_name + ' to ' + new_name
	cd('/Server/' + old_name)
	cmo.setName(new_name)
	
def build_wkas():
	count = 1
	soa_wkas = ''
	cd('/')
	for server in cmo.getServers():
		servername = str(server.getName())
		if 'SOA' in servername:
			if not soa_wkas:
				soa_wkas = '-Dtangosol.coherence.wka' + str(count) + '=' + machine_assignments[servername]
			else:
				soa_wkas = soa_wkas + ' -Dtangosol.coherence.wka' + str(count) + '=' + machine_assignments[servername]
			count += 1
	print '[DEBUG] ' + soa_wkas
	return soa_wkas
				
def set_wka(servername, base_wkas):
	print '>>> Setting well-known-addresses for ' + servername
	cd('/Server/' + servername)
	create(servername,'ServerStart')
	cd('ServerStart/' + servername)
	new_wkas = base_wkas + ' -Dtangosol.coherence.localhost=' + machine_assignments[servername]
	set ('Arguments', new_wkas)
	
def disable_hostname_verification(servername):
	print '>> Creating SSL MBean for ' + servername
	cd('/Server/' + servername)
	create(servername,'SSL')
	print '>>> Disabling hostname verification for ' + servername
	cd('SSL/' + servername)
	cmo.setHostnameVerificationIgnored(java.lang.Boolean('true'))
	cmo.setHostnameVerifier('null')

#def enable_weblogic_plugin(servername):
#	print '>>> Enabling WebLogic Plug-in on ' + servername
#	cd('/Server/' + servername)
#	cmo.setWeblogicPluginEnabled(java.lang.Boolean('true'))

def update_log_config(servername):
    cd('/Server/' + servername)
    print '>>> Creating Log MBean for ' + servername
    create(servername,'Log')
    cd('Log/' + servername)
    print '>>>> Editing ' + servername + ' runtime log configuration'
    cmo.setRotationType('byTime')
    cmo.setRotateLogOnStartup(false)
    cmo.setFileName(log_dir + '/' + servername + '/' + servername + '.log')
    
    cd('/Server/' + servername)
    print '>>> Creating WebServer MBean for ' + servername
    create(servername,'WebServer')
    cd('WebServer/' + servername)
    create(servername,'WebServerLog')
    cd('WebServerLog/' + servername)
    print '>>>> Editing ' + servername + ' webserver log configuration'
    cmo.setRotationType('byTime')
    cmo.setRotateLogOnStartup(false)
    cmo.setFileName(log_dir + '/' + servername + '/access.log')
    
    cd('/Server/' + servername)
    print '>>> Creating DataSource MBean for ' + servername
    create(servername,'DataSource')
    cd('DataSource/' + servername)
    create(servername,'DataSourceLogFile')
    cd('DataSourceLogFile/' + servername)
    print '>>>> Editing ' + servername + ' datasource log configuration'
    cmo.setRotationType('byTime')
    cmo.setRotateLogOnStartup(false)
    cmo.setFileName(log_dir + '/' + servername + '/datasource.log')

def configure_tlogs(servername):
    cd('/Servers/' + servername)
    if cmo.getCluster() != None:
    	print '>>> Updating transaction log configuration for ' + servername
        cluster = cmo.getCluster().getName()
        cmo.setJMSThreadPoolSize(0)
        cmo.setXMLRegistry(None)
        cmo.setXMLEntityCache(None)
        
        cd('/Servers/' + servername)
        print '>>> Creating DefaultFileStore MBean for ' + servername
        create(servername,'DefaultFileStore')
        cd('DefaultFileStore/' + servername)
        cmo.setDirectory(tlog_loc + '/' + cluster + '/tlogs')
        
        cd('/Servers/' + servername)
        print '>>> Creating TransactionLogJDBCStore MBean for ' + servername
        create(servername,'TransactionLogJDBCStore')
        cd('TransactionLogJDBCStore/' + servername)
        cmo.setEnabled(false)
    else:
        print '>>> Skipping ' + servername + ' since it is not a member of a cluster'

# DEPLOY
# WebLogic Server Base
print '>> Read template: ' + wls_template
readTemplate(wls_template)
setOption('AppDir', app_dir)
setOption('DomainName', domain_name)
setOption('OverwriteDomain', 'true')
setOption('JavaHome', java_home)
setOption('ServerStartMode', start_mode)
print '>>> Set weblogic user credentials'
cd('/Security/base_domain/User/weblogic')
cmo.setPassword(admin_pw)

print '<< Writing base domain to disk'
writeDomain(domain_home)
closeTemplate()

# Add product-specific domain extensions
print '>> Read domain from disk: ' + domain_name
readDomain(domain_home)

# Add extension templates to the domain
for template in ucm_template_list:
	print '>> Adding template: ' + ucm_templates + template
	addTemplate(ucm_templates + template)
for template in soa_template_list:
	print '>> Adding template: ' + soa_templates + template
	addTemplate(soa_templates + template)
	
print '>> Setting application directory: ' + app_dir
setOption('AppDir', app_dir)

# Change server names
print '>> Update server names'
for old, new in new_server_names.items():
	update_server_name(old,new)
	
# Create clusters
print '>>> Create clusters and assign servers'
for cname, cserver in cluster_assignments.items():
	create_assign_cluster(cname)

print '<< Writing updated domain to disk'
updateDomain()
closeDomain()

# Modify settings after template deploys
print
print '>> Read domain from disk: ' + domain_name
readDomain(domain_home)

create_machines()

print '>> Configure datasources'
JDBCResources = cmo.getJDBCSystemResources()
for resource in JDBCResources:
	configure_datasource(resource.getName())

print '>> Updating Library assignments'
# Change XDO target to include UCM Cluster
assign('Library', 'oracle.xdo.runtime#1@11.1.1.3.0', 'Target', ucm_cluster_name)
assign('Library', 'oracle.soa.workflow.wc#11.1.1@11.1.1', 'Target', ipm_cluster_name + ',' + soa_cluster_name)
assign('AppDeployment', 'wsm-pm', 'Target', soa_cluster_name)
#assign('AppDeployment', 'NonJ2EEManagement#11.1.1', 'Target', 'AdminServer')

soa_only_libraries = [\
'oracle.soa.worklist.webapp#11.1.1@11.1.1',\
'oracle.rules#11.1.1@11.1.1',\
'oracle.sdp.client#11.1.1@11.1.1',\
'oracle.soa.rules_editor_dc.webapp#11.1.1@11.1.1',\
'oracle.soa.rules_dict_dc.webapp#11.1.1@11.1.1',\
'oracle.sdp.messaging#11.1.1@11.1.1',\
'oracle.soa.worklist#11.1.1@11.1.1',\
'oracle.soa.bpel#11.1.1@11.1.1',\
'oracle.soa.workflow#11.1.1@11.1.1',\
'oracle.soa.mediator#11.1.1@11.1.1',\
'oracle.soa.composer.webapp#11.1.1@11.1.1',\
'oracle.soa.ext#11.1.1@11.1.1']

for lib in soa_only_libraries:
	assign('Library', lib, 'Target', soa_cluster_name)

print '>> Updating JMS filestore locations'
cd ('/')
filestores = cmo.getFileStores()
for store in filestores:
	name = store.getName()
	store.setDirectory(os.getenv('DOMAIN_BASE') + '/' + os.getenv('DOMAIN_NAME') + '/resources/jms/' + name)

cd('/')
print '>> Setting front end HTTP attributes'
clusters = cmo.getClusters()
for cluster in clusters:
	clusterName=str(cluster.getName())
	cd('/Clusters/' + clusterName)
	set('FrontendHost', frontend_host)
	set('FrontendHTTPPort', 80)
	set('FrontendHTTPSPort', 443)

print '<< Writing updated domain to disk'
updateDomain()
closeDomain()

# Additional post-creation configuration changes
print
print '>> Read domain from disk: ' + domain_name
readDomain(domain_home)

servers = cmo.getServers()
print '>> Performing additional managed server configuration...'
base_wkas = build_wkas()
for server in servers:
	servername = str(server.getName())
	print '>>> Enabling WebLogic Plug-in on ' + servername
	server.setWeblogicPluginEnabled(java.lang.Boolean('true'))
	disable_hostname_verification(servername)
	print '>> Updating all log configurations'
	update_log_config(servername)
	configure_tlogs(servername)
	if 'SOA' in servername:
		set_wka(servername, base_wkas)
	
print '>> Creating Log MBean for domain'
cd('/')
create(domain_name, 'Log')
print '>>> Editing domain log configuration'
cd('/Log/' + domain_name)
cmo.setRotationType('byTime')
cmo.setRotateLogOnStartup(false)
cmo.setFileName(log_dir + '/' + domain_name + '.log')

print '[!!] >> Logs will now be located at: ' + log_dir
print '[!!] >> Transaction logs will now be located at: ' + tlog_loc + '/{Cluster_Name}/tlogs'
	
print '<< Writing updated domain to disk'
updateDomain()
print '> DOMAIN CREATE COMPLETE'
closeDomain()
exit()
