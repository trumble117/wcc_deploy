#!/usr/bin/python
#
# Johnathon Trumble
# john.trumble@oracle.com
# November 5, 2014
#
# TODO: Make a configurator for this file
#		Make the db_pw a dictionary so that datasources can have different passwords

import os, sys

# USER-DEFINED
ucm_cluster_name = 'UCM_Cluster' 		# Used for XDO assignment later
# Comma-separate server assignments to clusters
cluster_assignments = dict(UCM_Cluster='UCM_server1', URM_Cluster='URM_server1', CAP_Cluster='capture_server1')
# Create key:value pairs for servers to be created and the machine on which they will run (correspond to listen addresses)
machine_assignments = dict(UCM_server1='wccapp2', IBR_server1='wccapp2', URM_server='wccapp2', capture_server1='wccapp2')
machine_listen_addresses = ['wccapp2']
db_pw = 'welcome1'

# Templates
ucm_template_list = ['oracle.ucm.core_template_11.1.1.jar','oracle.ucm.cs_template_11.1.1.jar','oracle.ucm.ibr_template_11.1.1.jar','oracle.ucm.urm_template_11.1.1.jar','oracle.capture_template_11.1.1.jar']

# Grab environment variables
app_dir = os.getenv('DOMAIN_BASE') + '/' + os.getenv('DOMAIN_NAME') + '/aserver/applications'
java_home = os.getenv('JAVA_HOME')
nm_listen_port = os.getenv('NM_PORT')
domain_home = os.getenv('DOMAIN_HOME')
domain_name = os.getenv('DOMAIN_NAME')
ucm_templates = os.getenv('ECM_HOME') + '/common/templates/applications/'
wls_template = os.getenv('WL_HOME') + '/common/templates/domains/wls.jar'
admin_pw = os.getenv('ADMIN_PW')
# DB variables
db_url = os.getenv('DB_URL')
db_prefix = os.getenv('SCHEMA_PREFIX') + '_'

# DEFINITIONS
def create_machines():
	print '>>> Create machines and assign servers to them'
	servers = cmo.getServers()
	for i in range(len(machine_listen_addresses)):
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
				print '>>>> Encountered AdminServer, skipping machine assingment'
			else:
				cur_server = machine_assignments[server.getName()]
				if cur_server == machine_listen_addresses[i]:
					print '>>>> Assigning ' + server.getName() + ' to ' + machine.getName()
					server.setMachine(machine)
	cd('/')

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
	
# DEPLOY
# WebLogic Server Base
print '>> Read template: ' + wls_template
readTemplate(wls_template)
setOption('AppDir', app_dir)
setOption('DomainName', domain_name)
setOption('OverwriteDomain', 'true')
setOption('JavaHome', java_home)
setOption('ServerStartMode', 'dev')
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

# Create clusters
print '>>> Create clusters and assign servers'
for cname, cserver in cluster_assignments.items():
	create_assign_cluster(cname)

print '<< Writing updated domain to disk'
updateDomain()
closeDomain()

# Modify settings after template deploys
print '>> Read domain from disk: ' + domain_name
readDomain(domain_home)

create_machines()

print '>> Configure datasources'
JDBCResources = cmo.getJDBCSystemResources()
for resource in JDBCResources:
	configure_datasource(resource.getName())

# Change XDO target to include UCM Cluster
assign('Library', 'oracle.xdo.runtime#1@11.1.1.3.0', 'Target', ucm_cluster_name)

print '>> Enabling WebLogic Plug-in on servers'
cd('/')
servers = cmo.getServers()
for server in servers:
	serverName=str(server.getName())
	cd('/Servers/' + serverName)
	cmo.setWeblogicPluginEnabled(java.lang.Boolean('true'))

print '<< Writing updated domain to disk'
updateDomain()
print '> DOMAIN CREATE COMPLETE'
closeDomain()
exit()
