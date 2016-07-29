#!/usr/bin/env bash

set -eo pipefail

# Get libraries
cd /usr/local/src
#wget "http://apache.rediris.es/apr/apr-${APR_VERSION}.tar.bz2"
wget "http://apache.rediris.es/tomcat/tomcat-connectors/native/${TCN_VERSION}/source/tomcat-native-${TCN_VERSION}-src.tar.gz"

# Uncompress and build apache APR
#tar -xjvf apr-${APR_VERSION}.tar.bz2
#cd apr-${APR_VERSION}
#./configure --prefix=/usr
#make
#make install

# Uncompress and build tcnative
export JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-oracle
cd /usr/local/src
tar -xzvf tomcat-native-${TCN_VERSION}-src.tar.gz
cd tomcat-native-${TCN_VERSION}-src/jni/native
./configure --prefix=/usr --with-java-home=$JAVA_HOME
#./configure --prefix=/usr --with-apr=/usr --with-java-home=$JAVA_HOME
make
make install

# Clean up. Leave wget and openssl, otherwise java7 is removed too.
rm -rf /usr/local/src/*
