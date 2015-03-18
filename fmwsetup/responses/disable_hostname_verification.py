#!/usr/bin/python
#
# Johnathon Trumble
# john.trumble@oracle.com
# March 18, 2015
#
# CHANGELOG
# 03/18/2015 - Fixed admin URL to proper format

import os

admin_server = os.getenv('ADMIN_SERVER_HOST')
admin_pw = os.getenv('ADMIN_PW')

connect('weblogic',admin_pw,'t3://' + admin_server + ':7001')
edit()
startEdit()
print '>> Disabling hostname verification on servers (Re-enable after certificate setup)'
cd('/')
servers = cmo.getServers()
for server in servers:
        serverName=str(server.getName())
        cd('/Servers/' + serverName + '/SSL/' + serverName)
        cmo.setHostnameVerificationIgnored(java.lang.Boolean('true'))
        cmo.setHostnameVerifier('null')

activate()
exit()
