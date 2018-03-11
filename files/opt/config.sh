#!/bin/bash

export PENTAHO_HOME=/opt/pentaho-server
cd ${PENTAHO_HOME} || exit -1

if [ $# -lt 4 ]; then
    >&2 echo "Error: not enough parameters. Usage:"
    >&2 echo "$0 [mysql_server] [mysql_port] [table_prefix] [password]"
    exit -1
fi

# Fix an issue with missing validation file in Pentaho
# see http://jira.pentaho.com/browse/BISERVER-11746
export PROP_FILE=${PENTAHO_HOME}/tomcat/webapps/pentaho/WEB-INF/classes/validation.properties
if ! [ -f "${PROP_FILE}" ]; then
    touch "${PROP_FILE}"
fi

# Configuration file golden repository and scratch space
export CONFIG_GOLDEN=/opt/config
export CONFIG_HOME=/opt/scratch
mkdir -p "${CONFIG_HOME}"

    
# Get configuration parameters:
# 1: MYSQL Server name
# 2: MYSQL Server port
# 3: MYSQL Database name prefixes
# 4: MYSQL User passwords
export MYSQL_SERVER=${1:-mysql}
export MYSQL_PORT=${2:-3306}
export MYSQL_PREFIX=${3:-v1_}
export MYSQL_PASSWORD=${4:-Changeme}

# Replace placeholders in configuration files
cp -f ${CONFIG_GOLDEN}/* ${CONFIG_HOME}
for i in ${CONFIG_HOME}/*; do
    sed -i "s/%SERVER%/${MYSQL_SERVER}/g" "$i"
    sed -i "s/%PORT%/${MYSQL_PORT}/g" "$i"
    sed -i "s/%PREFIX%/${MYSQL_PREFIX}/g" "$i"
    sed -i "s/%PASSWORD%/${MYSQL_PASSWORD}/g" "$i"
done

# Remove copy of server.xml made automatically by tomcat
# See https://anonymousbi.wordpress.com/2013/12/15/pentaho-bi-server-5-0-1ce-mysql-installation-guide/
rm -f ${PENTAHO_HOME}/tomcat/conf/Catalina/localhost/pentaho.xml

# Database parameters. See
# https://help.pentaho.com/Documentation/6.0/0F0/0K0/040/0B0
mv -f ${CONFIG_HOME}/pentaho-solutions.system.audit_sql.xml ${PENTAHO_HOME}/pentaho-solutions/system/audit_sql.xml
mv -f ${CONFIG_HOME}/pentaho-solutions.system.hibernate.hibernate-settings.xml ${PENTAHO_HOME}/pentaho-solutions/system/hibernate/hibernate-settings.xml
mv -f ${CONFIG_HOME}/pentaho-solutions.system.hibernate.mysql5.hibernate.cfg.xml ${PENTAHO_HOME}/pentaho-solutions/system/hibernate/mysql5.hibernate.cfg.xml
mv -f ${CONFIG_HOME}/pentaho-solutions.system.jackrabbit.repository.xml ${PENTAHO_HOME}/pentaho-solutions/system/jackrabbit/repository.xml
mv -f ${CONFIG_HOME}/pentaho-solutions.system.quartz.quartz.properties ${PENTAHO_HOME}/pentaho-solutions/system/quartz/quartz.properties
mv -f ${CONFIG_HOME}/tomcat.webapps.pentaho.META-INF.context.xml ${PENTAHO_HOME}/tomcat/webapps/pentaho/META-INF/context.xml

# CATALINA_OPTS Settings. See
# https://help.pentaho.com/Documentation/6.0/0F0/0K0/070/0B0
mv -f ${CONFIG_HOME}/tomcat.bin.startup.sh ${PENTAHO_HOME}/tomcat/bin/startup.sh

# Remove dependencies on HSQLDB. See
# https://anonymousbi.wordpress.com/2013/12/15/pentaho-bi-server-5-0-1ce-mysql-installation-guide/
mv -f ${CONFIG_HOME}/pentaho-solutions.system.applicationContext-spring-security-hibernate.properties ${PENTAHO_HOME}/pentaho-solutions/system/applicationContext-spring-security-hibernate.properties
mv -f ${CONFIG_HOME}/tomcat.webapps.pentaho.WEB-INF.web.xml ${PENTAHO_HOME}/tomcat/webapps/pentaho/WEB-INF/web.xml

# Tomcat logging settings. See
# http://forums.pentaho.com/showthread.php?189137-Log-rotation-for-Pentaho-5-3-BI-server
mv -f ${CONFIG_HOME}/tomcat.conf.logging.properties ${PENTAHO_HOME}/tomcat/conf/logging.properties

# Dump the required SQL statements to create the databases
export SQL_HOME=/opt/mysql
for i in ${SQL_HOME}/*; do
    sed "s/%SERVER%/${MYSQL_SERVER}/g;s/%PORT%/${MYSQL_PORT}/g;s/%PREFIX%/${MYSQL_PREFIX}/g;s/%PASSWORD%/${MYSQL_PASSWORD}/g" "$i"
    echo ""
done

