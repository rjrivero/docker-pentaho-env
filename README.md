Pentaho-BI container
====================

Pentaho BI Community Edition container, with helper script to configure the Pentaho environment to use mysql as the repository, and reverse proxy based on NGNIX

To build the container:

```
git clone https://github.com/rjrivero/docker-pentaho-env.git
cd docker-pentaho-env

# To build the x86 version
docker build -t pentaho-env .
```

To run:

```
docker run --rm -p 80:80 \
           -v /opt/pentaho/biserver-ce:/opt/biserver-ce \
           --name pentaho pentaho-env
```

The container exposes **port 80**.

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
docker run --rm -it -v /opt/pentaho/biserver-ce:/opt/biserver-ce pentaho-env \
    /opt/config.sh mysql.server.com 3306 prefix_ MySecret1234 > script.sql
```

The output of this command is the set of SQL statements to run in the database, in order to create the required schemas, users and passwords.

Reverse Proxy
-------------

This container includes a nginx server which proxies all incoming requests to the pentaho bi server. This proxy is intended to mask all incoming requests to Pentaho as sourced from localhost, so that all its features are available remotely.

However, this nginx server can be configured using environment variables to proxy any url path. The container recognized the following pattern for environment variables:

  - PROXY_PREFIX_*xxx* = *URL*: proxies any request under /*xxx* to *URL/xxx*
  - PROXY_PREFIX_*xxx* = *URL;PATH*: tries to serve any request under /*xxx* with static files in *PATH*. If no file is found, proxies the request to *URL/xxx*

for instance,

  - PROXY_PREFIX_REMOTE="http://remote.server:3000" will forward any request under /config to http://remote.server:3000/remote
  - PROXY_PREFIX_CONFIG="http://config.server:3000;/opt/www" will try to serve any request under /config with static files in /opt/www, and fallback to http://config.server:3000/config if no static file is found.

Other environment variables
---------------------------

If the embedded nginx server is to be run behind a reverse proxy too, two environment variables must be provided:

  - PROXY_PORT: port number of the proxy, defualt 80.
  - PROXY_SCHEME: scheme used by the proxy, default http.

Typically, if deploying behind a ssl proxy, the values of these environment variables should be:

  - PROXY_PORT=443
  - PROXY_SCHEME=https

