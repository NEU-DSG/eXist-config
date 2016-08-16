# eXist-config

This repository contains some helpful transformations and shell scripts for setting up [eXist-DB version 2.2](http://exist-db.org) on a production server and maintaining it.

One workflow for setting up and configuring eXist is given below.

Additional resources:
* [The eXist-DB documentation](http://exist-db.org/exist/apps/doc/) contains guides on installation, configuration, indexing, backups, and more. However, this repository exists (badum psh) because information on creating a production instance can be hard to distill.
* [_eXist_, by Siegel and Retter](http://shop.oreilly.com/product/0636920026525.do) includes a great deal of information on eXist's architecture, packages, and services. Chapter 8, on security, is especially useful.

## Installing eXist

Keep the default data directory (should look like: $EXIST_HOME/webapp/WEB-INF/data). Install these packages: doc, fundocs, monex, xqjson.

Start eXist-db for the first time. Make sure the above apps are installed. Make sure your admin password works.

Remove $EXIST_HOME/autodeploy.

### Making eXist a system service

Shut down eXist.

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
* Add the eXist service to chkconfig for runlevel management. This allows eXist to shut down and start up with the server.

`chkconfig --list existdb`
* Should show: "exist            0:off    1:off    2:on    3:on    4:on    5:on    6:off"

`sudo reboot`

`service existdb status`
* Should say eXist is running.

## Configuring eXist

IMPORTANT: Shut down and quit eXist before making any changes to eXist's configuration files!

Several key files you should know about:
* $EXIST_HOME/conf.xml
* $EXIST_HOME/tools/jetty/etc/jetty.xml
* $EXIST_HOME/webapp/WEB-INF/controller-config.xml
* $EXIST_HOME/webapp/WEB-INF/web.xml

### eXist configuration file

In $EXIST_HOME/conf.xml:
* Comment out .xar application autodeployment trigger at `//startup/triggers`
* Change `//indexer/@preserve-whitespace-mixed-content` to "yes"
* Change `//indexer/@stemming` to "yes"
* Change `//serializer/@enable-xinclude` to "no"
* Within `//transformer[@class eq 'net.sf.saxon.TransformerFactoryImpl']`, add this line: 
<pre><code>&lt;attribute name="http://saxon.sf.net/feature/recoveryPolicyName" value="recoverWithWarnings" type="string"/&gt;
</code></pre>
* Comment out `//builtin-modules/module[uri="http://exist-db.org/xquery/examples" | uri="http://exist-db.org/xquery/mail" | uri="http://exist-db.org/xquery/xslfo"]`
* Set `//builtin-modules/module/parameter[@name="evalDisabled"]/@value` to "true"

#### Backups

Within `//scheduler`, create a database backup policy following either the consistency check or data backup examples commented out by default. Below is an example of a consistency check which runs every day, creating incremental backups (containing changed data since the last backup) afterward. The database is backed up in full every week. Backups and log files are zipped and stored in the directory $EXIST_DATADIR/backup/consistency.
<pre><code>&lt;job type="system" name="checkAndBackup" 
    class="org.exist.storage.ConsistencyCheckTask"
    cron-trigger="0 0 1 1/1 * ?"&gt;
    &lt;parameter name="output" value="backup/consistency"/&gt;
    &lt;parameter name="backup" value="yes"/&gt;
    &lt;parameter name="incremental" value="yes"/&gt;
    &lt;parameter name="incremental-check" value="yes"/&gt;
    &lt;parameter name="max" value="7"/&gt;
    &lt;parameter name="zip" value="yes"/&gt;
  &lt;/job&gt;
</code></pre>

### Jetty server configuration file

In $EXIST_HOME/tools/jetty/etc/jetty.xml:
* If desired, change `//Call[@name='addConnector']//SystemProperty[@name='jetty']/@default` to a different port
	* If changing the port, update port references in $EXIST_HOME/client.properties
* Change `//Ref[@id='RequestLog']//Set[@name='LogTimeZone']` to your time zone ("EST", for example)

### Network servlet management files

In $EXIST_HOME/webapp/WEB-INF/controller-config.xml:
* Comment out `//forward[@servlet='atom']`
* Comment out all `//forward[@servlet='AxisServlet']`
* Comment out `//forward[@servlet='AdminServlet']`

In $EXIST_HOME/webapp/WEB-INF/web.xml:
* Comment out `//servlet[servlet-name='AxisServlet']`
* Comment out `//servlet[servlet-name='AdminServlet']`
* Comment out `//servlet[servlet-name='AtomServlet']`
