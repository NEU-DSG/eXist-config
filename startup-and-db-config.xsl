<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  exclude-result-prefixes="xs" version="2.0">
  <!-- Configure eXist's startup and database behaviors.                    -->
  <!-- For use on:                                                          -->
  <!--        $EXIST_HOME/conf.xml                                          -->
  <!--   last modified: Feb 2016                                            -->
  <!--   author: Ashley M. Clark                                            -->
  <!-- CHANGELOG                                                            -->
  <!-- 2016-02-22: Removed RESTXQ from disabled servlets and updated backup 
    policy to use incremental backup with consistency checks. ~Ashley       -->
  
  <xsl:import href="config-manips.xsl"/>
  <xsl:output indent="yes"/>
  
  <xsl:param name="backupDir" select="'backup/consistency'"/>
  
  <!-- Do not use application autodeployment. -->
  <xsl:template match="startup//trigger[@class='org.exist.repo.AutoDeploymentTrigger']">
    <xsl:call-template name="commentOut">
      <xsl:with-param name="unwantedNode">
        <xsl:copy>
          <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <!-- Preserve whitespace when it exists in nodes with both textual and 
    elemental content. -->
  <xsl:template match="indexer/@preserve-whitespace-mixed-content">
    <xsl:attribute name="preserve-whitespace-mixed-content">yes</xsl:attribute>
  </xsl:template>
  
  <!-- Use word stemming. -->
  <xsl:template match="indexer/@stemming">
    <xsl:attribute name="stemming">yes</xsl:attribute>
  </xsl:template>
  
  <!-- Backup the database incrementally once a day. Every 7 incremental 
    backups, create a full (compressed) backup. -->
  <xsl:template match="comment()[contains(.,'org.exist.storage.ConsistencyCheckTask')]">
    <xsl:copy/>
    <job type="system" name="checkAndBackup" 
      class="org.exist.storage.ConsistencyCheckTask"
      cron-trigger="0 0 1 1/1 * ?">
      <parameter name="output" value="{$backupDir}"/>
      <parameter name="backup" value="yes"/>
      <parameter name="incremental" value="yes"/>
      <parameter name="incremental-check" value="yes"/>
      <parameter name="max" value="7"/>
      <parameter name="zip" value="yes"/>
    </job>
  </xsl:template>
  
  <!-- Allow XSLT stylesheets to be run on XML display. -->
  <xsl:template match="serializer/@enable-xsl">
    <xsl:attribute name="enable-xsl">yes</xsl:attribute>
  </xsl:template>
  
  <!-- Have Saxon 9.4 output XSL warnings as a type of error. Use the parameter 
    "exist:stop-on-error" to have eXist recover from these warnings and supply 
    output. -->
  <!-- Saxon 9.6 implements an "UnfailingErrorListener" class which will make 
    warnings recoverable without special handling, and output warnings to a log 
    file. However, eXist 2.2 has a dependency on BetterFORMS, which has a 
    dependency on Saxon 9.4 in turn.  -->
  <xsl:template match="transformer[@class eq 'net.sf.saxon.TransformerFactoryImpl']">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <attribute name="http://saxon.sf.net/feature/recoveryPolicyName" value="recoverWithWarnings" type="string"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Do not use the following built-in modules: -->
  <xsl:template match="builtin-modules/module[@uri='http://exist-db.org/xquery/examples' or
                                              @uri='http://exist-db.org/xquery/mail'  or
                                              @uri='http://exist-db.org/xquery/xslfo']">
    <xsl:call-template name="commentOut">
      <xsl:with-param name="unwantedNode">
        <xsl:copy>
          <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <!-- Disable util:eval functions. -->
  <xsl:template match="builtin-modules/module[@uri='http://exist-db.org/xquery/util']/parameter[@name='evalDisabled']/@value">
    <xsl:attribute name="value">true</xsl:attribute>
  </xsl:template>
  
</xsl:stylesheet>
