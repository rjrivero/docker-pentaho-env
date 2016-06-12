Pentaho-BI container
====================

Pentaho BI Community Edition container, with helper script to configure the Pentaho environment to use mysql as the repository.

To build the container:

```
git clone https://github.com/rjrivero/docker-pentaho-env.git
cd docker-pentaho-env

# To build the x86 version
docker build -t pentaho-env .
```

To run:

```
docker run --rm -p 8080:8080 \
           -v /opt/pentaho/biserver-ce:/opt/biserver-ce \
           --name pentaho pentaho-env
```

The container exposes **port 8080**.

Volumes
-------

Pentaho runs from directory **/opt/biserver-ce**. You must:

  - Download the Pentaho Business Analytics Platform - Community Edition software from http://community.pentaho.com
  - Unzip it somewhere in your host server, say **/opt/pentaho**
  - Mount the resulting **/opt/pentaho/biserver-ce** folder to the container, in the **/opt/biserver-ce** path.

  - Install the [Community Distributed Cache](http://pedroalves-bi.blogspot.com.es/2012/05/cdc-community-distributed-cache.html) from the marketplace.

    - You may need to manually copy the files from *solution/system/cdc/pentaho-lib* to *tomcat/webapps/pentaho/WEB-INF/lib*.
The container provides the [standalone node for CDC](http://ci.pentaho.com/job/pentaho-cdc-5x/lastSuccessfulBuild/artifact/cdc-pentaho5/dist/cdc-pentaho5-redist-SNAPSHOT.zip) already running, for the benefit of your CDC.

Configuration
-------------

The container includes a helper script to help configure the Pentaho installation to connect to the MySQL repository. Run the command **/opt/config.sh** inside the container, providing the following four parameters:

  - MySQL server name
  - MySQL server port
  - Prefix to add to the databases, to make the names unique
  - Password for the quartz and jackrabbit users

e.g, run:

```
docker run --rm -it -v /opt/pentaho/biserver-ce:/opt/biserver-ce pentaho-env \
    /opt/config.sh mysql.server.com 3306 prefix_ MySecret1234 > script.sql
```

The output of this command is the set of SQL statements to run in the database, in order to create the required schemas, users and passwords.

Environment variables
---------------------

If Pentaho is to be run behind a reverse proxy, two environment variables must be provided:

  - PROXY_PORT: port number of the proxy, defualt 80.
  - PROXY_SCHEME: scheme used by the proxy, default http.

Typically, if deploying behind a ssl proxy, the values of these environment variables should be:

  - PROXY_PORT=443
  - PROXY_SCHEME=https

Caching with CDC
----------------

You can install the [Community Distributed Cache](http://pedroalves-bi.blogspot.com.es/2012/05/cdc-community-distributed-cache.html) from the marketplace to improve caching control (allows you to clean the CDA cache of a single dashboard, selectively).

Once the plugin is installed, you may need to manually copy the files from *solution/system/cdc/pentaho-lib* to *tomcat/webapps/pentaho/WEB-INF/lib*, and reboot the server.

For your convenience, this container includes the [standalone node for CDC](http://ci.pentaho.com/job/pentaho-cdc-5x/lastSuccessfulBuild/artifact/cdc-pentaho5/dist/cdc-pentaho5-redist-SNAPSHOT.zip) already running, so CDC should be up and running as soon as you install it.

