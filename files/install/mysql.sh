#!/usr/bin/env bash

set -eo pipefail

# Get libraries
cd /usr/local/src
wget "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONN_VERSION}.tar.gz"

# Uncompress MySQL connector
tar -xzvf "mysql-connector-java-${MYSQL_CONN_VERSION}.tar.gz"
mv mysql-connector-java-${MYSQL_CONN_VERSION}/mysql-connector-java-${MYSQL_CONN_VERSION}-bin.jar /usr/local/lib

rm -rf /usr/local/src/*
