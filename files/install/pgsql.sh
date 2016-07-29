#!/usr/bin/env bash

set -eo pipefail

# Get libraries
cd /usr/local/src
wget "https://jdbc.postgresql.org/download/postgresql-${PGSQL_CONN_VERSION}.jar"

# Move postgresql connector to /usr/local/lib
mv postgresql-${PGSQL_CONN_VERSION}.jar /usr/local/lib

# Clean up
rm -rf /usr/local/src/*
