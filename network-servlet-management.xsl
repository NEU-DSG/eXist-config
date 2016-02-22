<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:ex="http://exist.sourceforge.net/NS/exist"
  xmlns:web="http://java.sun.com/xml/ns/j2ee"
  exclude-result-prefixes="xs ex web"
  version="2.0">
  <!-- Configure the servlets that eXist uses and recognizes.               -->
  <!-- For use on:                                                          -->
  <!--        $EXIST_HOME/webapp/WEB-INF/controller-config.xml              -->
  <!--        $EXIST_HOME/webapp/WEB-INF/web.xml                            -->
  <!--   last modified: Feb 2016                                            -->
  <!--   author: Ashley M. Clark                                            -->
  <!-- CHANGELOG                                                            -->
  <!-- 2016-02-22: Removed RESTXQ from disabled servlets. ~Ashley           -->
  
  <xsl:import href="config-manips.xsl"/>
  <xsl:output indent="yes" omit-xml-declaration="yes"/>
  
  <!-- List the servlets to disable here. -->
  <xsl:variable name="disabledServlet" 
    select="( 'milton', 
              'AtomServlet',
              'AxisServlet',
              'AdminServlet', 
              'JMXServlet')"/>
  
  <xsl:template match="ex:forward[@servlet=$disabledServlet] | 
                        web:servlet[web:servlet-name=$disabledServlet]">
    <xsl:call-template name="commentOut">
      <xsl:with-param name="unwantedNode">
        <xsl:copy-of select="."/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
</xsl:stylesheet>