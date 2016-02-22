# Your eXist-DB and You

This repository contains some helpful transformations and shell scripts for setting up eXist DB on a production server and maintaining it.



## Installing eXist

Keep the default data directory (should look like: $EXIST_HOME/webapp/WEB-INF/data). Install these packages: doc, fundocs, monex, xqjson.

Start eXist-db for the first time. Make sure the above apps are installed. Make sure your admin password works.

Remove $EXIST_HOME/autodeploy.

### Making eXist a system service

Stop eXist.

Create an eXist user with $EXIST_HOME as its home directory: `sudo useradd -d $EXIST_HOME exist`

Make sure $EXIST_HOME is owned by exist:exist.

`sudo vi $EXIST_HOME/tools/wrapper/bin/exist.sh`
* Change "APP_NAME" to "existdb"
* Uncomment the line starting with "RUN\_AS_USER". Add "exist" to the end of the line.
* Add "true" to the "USE_SYSTEMD" flag.

`sudo $EXIST_HOME/tools/wrapper/bin/exist.sh install`

`sudo vi $EXIST_HOME/tools/wrapper/conf/wrapper.conf`
* Make sure that the path for "wrapper.java.command" points to the latest version of Java.

`service existdb status`
* Should say eXist is stopped. Don't bring it up yet.

`sudo chkconfig --add existdb`
* Add the eXist service to chkconfig for runlevel management.

`chkconfig --list existdb`
* Should show: "exist            0:off    1:off    2:on    3:on    4:on    5:on    6:off"

`sudo reboot`

`service existdb status`
* Should say eXist is running.

## Configuring eXist

IMPORTANT: Shut down and quit eXist before making any changes to eXist's configuration files!

There are several key files you should know about:
* $EXIST_HOME/conf.xml
* $EXIST_HOME/tools/jetty/etc/jetty.xml
* $EXIST_HOME/webapp/WEB-INF/controller-config.xml
* $EXIST_HOME/webapp/WEB-INF/web.xml

### eXist's configuration file

In $EXIST_HOME/conf.xml:
* Comment out .xar application autodeployment trigger at //startup/triggers
* Change //indexer/@preserve-whitespace-mixed-content to "yes"
* Change //indexer/@stemming to "yes"
* Change //serializer/@enable-xsl to "yes"
* Comment out //builtin-modules/module[uri="http://exist-db.org/xquery/examples" | uri="http://exist-db.org/xquery/mail" | uri="http://exist-db.org/xquery/xslfo"]
* Set //builtin-modules/module/parameter[@name="evalDisabled"]/@value to "true"

### Jetty server configuration file

In $EXIST_HOME/tools/jetty/etc/jetty.xml:
* If desired, change //Call[@name='addConnector']//SystemProperty[@name='jetty']/@default to a different port
	* If changing the port, update port references in $EXIST_HOME/client.properties
* Change //Ref[@id='RequestLog']//Set[@name='LogTimeZone'] to your time zone ("EST", for example)

### Network servlet management files

In $EXIST_HOME/webapp/WEB-INF/controller-config.xml:
* Comment out //forward[@servlet='milton']
* Comment out //forward[@servlet='atom']
* Comment out all //forward[@servlet='AxisServlet']
* Comment out //forward[@servlet='AdminServlet']
* Comment out //forward[@servlet='JMXServlet']
* Comment out //forward[@servlet='XQueryServlet']

In $EXIST_HOME/webapp/WEB-INF/web.xml:
* Comment out //servlet[servlet-name='JMXServlet']
* Comment out //servlet[servlet-name='milton']
* Comment out //servlet[servlet-name='AxisServlet']
* Comment out //servlet[servlet-name='AdminServlet']
* Comment out //servlet[servlet-name='AtomServlet']
