#!/usr/bin/env bash

set -eo pipefail

# install dependencies
apt-get -qq update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
	wget build-essential openssl unzip libssl-dev

# Get libraries
cd /usr/local/src
wget "https://jdbc.postgresql.org/download/postgresql-${PGSQL_CONN_VERSION}.jar"
wget "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONN_VERSION}.tar.gz"
wget "http://apache.rediris.es/apr/apr-${APR_VERSION}.tar.bz2"
wget "http://apache.rediris.es/tomcat/tomcat-connectors/native/${TCN_VERSION}/source/tomcat-native-${TCN_VERSION}-src.tar.gz"
wget "http://apache.rediris.es/logging/log4j/extras/${LOG4J_EXTRAS_VERSION}/apache-log4j-extras-${LOG4J_EXTRAS_VERSION}-bin.tar.gz"
wget "http://ci.pentaho.com/job/pentaho-cdc-5x/lastSuccessfulBuild/artifact/cdc-pentaho5/dist/cdc-pentaho5-redist-SNAPSHOT.zip"

# Uncompress MySQL connector
tar -xzvf "mysql-connector-java-${MYSQL_CONN_VERSION}.tar.gz"
mv mysql-connector-java-${MYSQL_CONN_VERSION}/mysql-connector-java-${MYSQL_CONN_VERSION}-bin.jar /usr/local/lib

# Move postgresql connector to /usr/local/lib
mv postgresql-${PGSQL_CONN_VERSION}.jar /usr/local/lib

# Uncompress log4j extras
tar -xzvf apache-log4j-extras-${LOG4J_EXTRAS_VERSION}-bin.tar.gz
mv apache-log4j-extras-${LOG4J_EXTRAS_VERSION}/apache-log4j-extras-${LOG4J_EXTRAS_VERSION}.jar /usr/local/lib

# Uncompress and build apache APR
tar -xjvf apr-${APR_VERSION}.tar.bz2
cd apr-${APR_VERSION}
./configure --prefix=/usr
make
make install

# Uncompress and build tcnative
export JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-oracle
cd /usr/local/src
tar -xzvf tomcat-native-${TCN_VERSION}-src.tar.gz
cd tomcat-native-${TCN_VERSION}-src/jni/native
./configure --prefix=/usr --with-apr=/usr \
	--with-java-home=$JAVA_HOME
make
make install

# Uncompress CDC standalone node
cd /usr/local/src
mkdir hazelcast
cd hazelcast
unzip ../cdc-pentaho5-redist-SNAPSHOT.zip
chmod 0755 launch-hazelcast.sh
cd ..
mv hazelcast /opt

# Clean up. Leave wget and openssl, otherwise java7 is removed too.
DEBIAN_ENVIRONMENT=noninteractive apt-get remove -y \
    build-essential libssl-dev
DEBIAN_ENVIRONMENT=noninteractive apt-get autoremove -y
apt-get clean -y
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
rm -rf /var/cache/oracle-jdk${JAVA_VERSION}-installer
rm -rf /usr/lib/jvm/java-${JAVA_VERSION}-oracle/src.zip
rm -rf /usr/local/src/*
