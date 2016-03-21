Pentaho-BI container
====================

Pentaho BI Community Edition container, with helper script to configure the Pentaho environment to use mysql as the repository.

To build the container:

```
git clone https://bitbucket.org/five_corp/docker-pentaho.git
cd docker-pentaho

# To build the x86 version
docker build -t pentaho:master .
```

To run:

```
docker run --rm -p 8080:8080 \
           -v /opt/pentaho/biserver-ce:/opt/biserver-ce \
           --name pentaho pentaho:master
```

The container exposes **port 8080**.

Volumes
-------

Pentaho runs from directory **/opt/biserver-ce**. You must:

  - Download the Pentaho Business Analytics Platform - Community Edition
    software from http://community.pentaho.com
  - Unzip it somewhere in your host server, say **/opt/pentaho**
  - Mount the resulting **/opt/pentaho/biserver-ce** folder to the container, in the **/opt/biserver-ce** path.

Configuration
-------------

The container includes a helper script to help configure the Pentaho installation to connect to the MySQL repository. Run the command **/opt/config.sh** inside the container, providing the following four parameters:

  - MySQL server name
  - MySQL server port
  - Prefix to add to the databases, to make the names unique
  - Password for the quartz and jackrabbit users

e.g, run:

```
docker run --rm -it -v /opt/pentaho/biserver-ce:/opt/biserver-ce \
    /opt/config.sh mysql.server.com 3306 prefix_ MySecret1234 > script.sql
```

The output of this command is the set of SQL statements to run in the database, in order to create the required schemas, users and passwords.

Environment variables
---------------------

If the instance is to be run behind a reverse proxy, two environment variables
must be provided:

  - PROXY_PORT: port number of the proxy.
  - PROXY_SCHEME: scheme used by the proxy.

Typically, if deploying behind a ssl proxy, the values of these environment
variables should be:

  - PROXY_PORT=443
  - PROXY_SCHEME=https

