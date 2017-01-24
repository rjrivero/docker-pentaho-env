#FROM isuper/java-oracle:server_jre_7
FROM phusion/baseimage:latest

MAINTAINER rjrivero

# Install dependencies.
#
# - xvfb to support headless reports
# - webupd8 ppa for java 7. See
# http://www.webupd8.org/2012/01/install-oracle-java-jdk-7-in-ubuntu-via.html
#
# Add pentaho user and group
#
# Create /opt/config and /opt/bootstrp folders for
# configuration files
RUN echo -e "\n" | add-apt-repository ppa:webupd8team/java && \
    apt-get -qq update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    oracle-java7-installer oracle-java7-set-default xvfb && \
    update-java-alternatives -s java-7-oracle && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    groupadd -g 1000 pentaho && \
    useradd  -g pentaho -u 1000 -m pentaho && \
    mkdir /opt/scratch && \
    chown pentaho:pentaho /opt/scratch

# Support software versions
# Get this version from https://dev.mysql.com/downloads/connector/j/
ENV MYSQL_CONN_VERSION 5.1.39
# Get this version from https://jdbc.postgresql.org/download.html
ENV PGSQL_CONN_VERSION 9.4.1208.jre7
# Get this version from https://apr.apache.org/download.cgi
ENV APR_VERSION 1.5.2
# Get this version from https://tomcat.apache.org/download-native.cgi
ENV TCN_VERSION 1.1.34
# Get this version from https://logging.apache.org/log4j/extras/
ENV LOG4J_EXTRAS_VERSION 1.2.17
# C3P0 connection pool from  https://sourceforge.net/projects/c3p0/
ENV C3P0_VERSION 0.9.5.2
ENV JAVA_VERSION 7

# Install libtcnative libraries and other dependencies
ADD files/install.sh /opt/install.sh
RUN /opt/install.sh && rm -f /opt/install.sh

# Now that all the heavy lifting (installing packages and dependencies)
# is done, begin the small tasks.

# First, add configuration and service files
ADD files/service /etc/service
ADD files/opt     /opt

# Pentaho must be downloaded, uncompressed and mounted as a volume
# in the path /opt/biserver-ce.
# Pentaho can be downloaded from: 
# http://downloads.sourceforge.net/project/pentaho/Business Intelligence Server/${PENTAHO_MAJOR}/biserver-ce-${PENTAHO_MINOR}.zip

VOLUME  /opt/biserver-ce
WORKDIR /opt/biserver-ce

# Set environment variables for Pentaho
ENV PENTAHO_JAVA_HOME "/usr/lib/jvm/java-${JAVA_VERSION}-oracle/jre"
ENV PENTAHO_JAVA "/usr/lib/jvm/java-${JAVA_VERSION}-oracle/jre/bin/java"

# If this instance is to be run behind a proxy, the proxy port and
# scheme must be given as environment variables, e.g.
# PROXY_PORT=443
# PROXY_SCHEME=https
ENV PROXY_PORT   "80"
ENV PROXY_SCHEME "http"

# Pentaho port
EXPOSE 8080
