#!/usr/bin/python
#
# Johnathon Trumble
# john.trumble@oracle.com
# March 19, 2015
#
# Modifies transaction log locations for domain resources
#
# CHANGELOG
# 

import os

admin_server = os.getenv('ADMIN_SERVER_HOST')
admin_pw = os.getenv('ADMIN_PW')
domain_name = os.getenv('DOMAIN_NAME')
domain_base = os.getenv('DOMAIN_BASE')

tlog_loc = os.getenv('DOMAIN_BASE') + "/" + os.getenv('DOMAIN_NAME') + "/resources/tlogs"

def configure_tlogs(servername):
    cd('/Servers/' + servername)
    if cmo.getCluster() != None:
        cluster = cmo.getCluster().getName()
        cmo.setJMSThreadPoolSize(0)
        cmo.setXMLRegistry(None)
        cmo.setXMLEntityCache(None)
        
        cd('/Servers/' + servername + '/DefaultFileStore/' + servername)
        cmo.setDirectory(tlog_loc + '/' + cluster + '/tlogs')
        
        cd('/Servers/' + servername + '/TransactionLogJDBCStore/' + servername)
        cmo.setEnabled(false)
    else:
        print '>>> Skipping ' + servername + ' since it is not a member of a cluster'

connect('weblogic',admin_pw,'t3://' + admin_server + ':7001')
edit()
startEdit()
print '>> Transaction logs will now be located at: ' + tlog_loc + '/{Cluster_Name}/tlogs'
print '>>> Editing server transaction log configurations'
cd('/')
servers = cmo.getServers()
for server in servers:
    configure_tlogs(str(server.getName()))

activate()
exit()