#!/usr/bin/python
#
# Johnathon Trumble
# john.trumble@oracle.com
# March 19, 2015
#
# Modifies default log locations for domain resources
#
# CHANGELOG
# 

import os

log_dir = os.getenv('LOG_DIR')
admin_server = os.getenv('ADMIN_SERVER_HOST')
admin_pw = os.getenv('ADMIN_PW')
domain_name = os.getenv('DOMAIN_NAME')

def update_log_config(servername):
    cd('/Servers/' + servername + '/Log/' + servername)
    cmo.setRotationType('byTime')
    cmo.setRotateLogOnStartup(false)
    cmo.setFileName(log_dir + '/' + servername + '/' + servername + '.log')
    
    cd('/Servers/' + servername + '/WebServer/' + servername + '/WebServerLog/' + servername)
    cmo.setRotationType('byTime')
    cmo.setRotateLogOnStartup(false)
    cmo.setFileName(log_dir + '/' + servername + '/access.log')
    
    cd('/Servers/' + servername + '/DataSource/' + servername + '/DataSourceLogFile/' + servername)
    cmo.setRotationType('byTime')
    cmo.setRotateLogOnStartup(false)
    cmo.setFileName(log_dir + '/' + servername + '/datasource.log')

connect('weblogic',admin_pw,'t3://' + admin_server + ':7001')
edit()
startEdit()
print '>> Logs will now be located at: ' + log_dir
print '>>> Editing server log configurations'
cd('/')
servers = cmo.getServers()
for server in servers:
    update_log_config(str(server.getName()))
    
print '>>> Editing domain log configuration'
cd('/Log/' + domain_name)
cmo.setRotationType('byTime')
cmo.setRotateLogOnStartup(false)
cmo.setFileName(log_dir + '/' + domain_name + '.log')

activate()
exit()