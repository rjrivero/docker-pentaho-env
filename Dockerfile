#FROM isuper/java-oracle:server_jre_7
FROM phusion/baseimage:latest

MAINTAINER rjrivero

# Install dependencies.
#
# - xvfb to support headless reports
# - webupd8 ppa for java 8. See
# http://www.webupd8.org/2012/01/install-oracle-java-jdk-7-in-ubuntu-via.html
#
# Add pentaho user and group
#
# Create /opt/config and /opt/bootstrp folders for
# configuration files
RUN echo -e "\n" | add-apt-repository ppa:webupd8team/java && \
    apt-get -qq update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    oracle-java8-installer oracle-java8-set-default xvfb \
    wget build-essential openssl unzip libssl-dev libapr1-dev && \
    update-java-alternatives -s java-8-oracle && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    groupadd -g 1000 pentaho && \
    useradd  -g pentaho -u 1000 -m pentaho && \
    mkdir /opt/scratch && \
    chown pentaho:pentaho /opt/scratch

# Support software versions
# Get this version from https://dev.mysql.com/downloads/connector/j/
ENV MYSQL_CONN_VERSION 5.1.39
# Get this version from https://jdbc.postgresql.org/download.html
ENV PGSQL_CONN_VERSION 9.4.1209
# Get this version from https://apr.apache.org/download.cgi
# ENV APR_VERSION 1.5.2
# Get this version from https://tomcat.apache.org/download-native.cgi
ENV TCN_VERSION 1.1.34
# Get this version from https://logging.apache.org/log4j/extras/
ENV LOG4J_EXTRAS_VERSION 1.2.17
ENV JAVA_VERSION 8

# Install libtcnative libraries and other dependencies
ADD files/install /opt/install
RUN /opt/install/mysql.sh
RUN /opt/install/pgsql.sh
RUN /opt/install/cdc.sh
RUN /opt/install/log4j.sh
RUN /opt/install/tcnative.sh
RUN rm -rf /opt/install

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
