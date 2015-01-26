#!/usr/bin/python
import os, sys, socket

# Setup variables
admin_pw = 'test1234#'
app_dir = os.getenv('DOMAIN_BASE') + '/' + os.getenv('DOMAIN_NAME') + '/aserver/applications'
nm_listen_port = os.getenv('NM_PORT')
db_url = 'jdbc:oracle:thin:@bvdb02.dev.oracle:1521/XE'
db_pw = 'welcome1'
db_prefix = 'BVDEV_'
template_dir = os.getenv('TEMPLATE_DIR')
domain_home = os.getenv('DOMAIN_HOME')

print '> Read template: WCC Domain...'
readTemplate(template_dir + '/dev.wcc.domain_1.0.0.0.jar')
setOption('AppDir', app_dir)

# Update WebLogic Password
cd('/Security/wcc_domain/User/weblogic')
cmo.setPassword('test1234#')

print '>> Configuring Datasources'
# Configure data sources
# CSDS
cd('/JDBCSystemResource/CSDS/JdbcResource/CSDS/JDBCDriverParams/NO_NAME_0')
cmo.setPasswordEncrypted(db_pw)
cmo.setUrl(db_url)

cd('Properties/NO_NAME_0/Property/user')
cmo.setValue(db_prefix + 'OCS')

# URMDS
cd('/JDBCSystemResource/URMDS/JdbcResource/URMDS/JDBCDriverParams/NO_NAME_0')
cmo.setPasswordEncrypted(db_pw)
cmo.setUrl(db_url)

cd('Properties/NO_NAME_0/Property/user')
cmo.setValue(db_prefix + 'URMSERVER')

# capture-ds
cd('/JDBCSystemResource/capture-ds/JdbcResource/capture-ds/JDBCDriverParams/NO_NAME_0')
cmo.setPasswordEncrypted(db_pw)
cmo.setUrl(db_url)

cd('Properties/NO_NAME_0/Property/user')
cmo.setValue(db_prefix + 'CAPTURE')

# capture-mds-ds
cd('/JDBCSystemResource/capture-mds-ds/JdbcResource/capture-mds-ds/JDBCDriverParams/NO_NAME_0')
cmo.setPasswordEncrypted(db_pw)
cmo.setUrl(db_url)

cd('Properties/NO_NAME_0/Property/user')
cmo.setValue(db_prefix + 'MDS')

print '>> Enabling WebLogic Plug-in'
cd('/')
servers = cmo.getServers()
for server in servers:
	serverName=str(server.getName())
	cd('/Servers/' + serverName)
	cmo.setWeblogicPluginEnabled(java.lang.Boolean('true'))

print '>> Setting Nodemanager Listen Port'
cd('/Machine/nsgwc/NodeManager/nsgwc')
cmo.setListenPort(int(nm_listen_port))

# These next three probably aren't necessary
#cd('/Server/AdminServer')
#cmo.setName('AdminServer')
#cmo.setListenPort(7001)
print '> Writing domain to disk'
writeDomain(domain_home)
print 'Domain create complete'
closeTemplate()
#exit()