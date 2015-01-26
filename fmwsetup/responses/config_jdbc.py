domain_home = os.getenv('DOMAIN_HOME')
domain_name = os.getenv('DOMAIN_NAME')
db_usernames = dict([('CSDS','OCS'), ('URMDS','URMSERVER'), ('capture-ds','CAPTURE'), ('capture-mds-ds','MDS')])
db_pw = 'welcome1'	   # Prompt for this?

# DB variables
db_url = os.getenv('DB_URL')
db_prefix = os.getenv('SCHEMA_PREFIX') + '_'

def configure_datasource(jdbc_name):
	print '>>> Configuring ' + jdbc_name
	print '[DEBUG] cd(\'/JDBCSystemResource/' + jdbc_name + '/JdbcResource/' + jdbc_name + '/JDBCDriverParams/NO_NAME_0\')'
	cd('/JDBCSystemResource/' + jdbc_name + '/JdbcResource/' + jdbc_name + '/JDBCDriverParams/NO_NAME_0')
	print '[DEBUG] cmo.setPasswordEncrypted(' + db_pw + ')'
	cmo.setPasswordEncrypted(db_pw)
	print '[DEBUG] cmo.setUrl(' + db_url + ')'
	cmo.setUrl(db_url)
	ls()
	
	print '[DEBUG] cd(\'Properties/NO_NAME_0/Property/user\')'
	cd('Properties/NO_NAME_0/Property/user')
	print '[DEBUG] cmo.setValue(' + db_prefix + db_usernames[jdbc_name] + ')'
	cmo.setValue(db_prefix + db_usernames[jdbc_name])
	ls()
	
print '>> Read domain from disk: ' + domain_name
readDomain(domain_home)

print '>> Begin: datasource setup'
JDBCResources = cmo.getJDBCSystemResources()
for resource in JDBCResources:
	configure_datasource(resource.getName())

print '<< Writing updated domain to disk'
updateDomain()
print 'JDBC UPDATE COMPLETE'
closeDomain()