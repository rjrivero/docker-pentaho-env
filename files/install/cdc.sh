#!/usr/bin/env bash

set -eo pipefail

# Get libraries
cd /usr/local/src
wget "http://ci.pentaho.com/job/pentaho-cdc-5x/lastSuccessfulBuild/artifact/cdc-pentaho5/dist/cdc-pentaho5-redist-SNAPSHOT.zip"

# Uncompress CDC standalone node
cd /usr/local/src
mkdir hazelcast
cd hazelcast
unzip ../cdc-pentaho5-redist-SNAPSHOT.zip
chmod 0755 launch-hazelcast.sh
cd ..
mv hazelcast /opt

# Clean up. Leave wget and openssl, otherwise java7 is removed too.
rm -rf /usr/local/src/*
