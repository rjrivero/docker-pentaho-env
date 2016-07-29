#!/usr/bin/env bash

set -eo pipefail

# Get libraries
cd /usr/local/src
wget "http://apache.rediris.es/logging/log4j/extras/${LOG4J_EXTRAS_VERSION}/apache-log4j-extras-${LOG4J_EXTRAS_VERSION}-bin.tar.gz"

# Uncompress log4j extras
tar -xzvf apache-log4j-extras-${LOG4J_EXTRAS_VERSION}-bin.tar.gz
mv apache-log4j-extras-${LOG4J_EXTRAS_VERSION}/apache-log4j-extras-${LOG4J_EXTRAS_VERSION}.jar /usr/local/lib

# Clean up. Leave wget and openssl, otherwise java7 is removed too.
rm -rf /usr/local/src/*
