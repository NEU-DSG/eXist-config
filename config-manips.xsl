<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY comment-start "&#xE501;">
  <!ENTITY comment-end "&#xE502;">
  <!ENTITY commented-start "&#xE503;">
  <!ENTITY commented-end "&#xE504;">
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  version="2.0">
  <!-- Templates for common XML manipulation.                               -->
  <!-- In order to allow elements to be commented out, this stylesheet uses -->
  <!--  the character map solution on pages 942-945 of _XSLT 2.0_ by        -->
  <!--  Michael Kay. The private use characters xE501 to xE504 are mapped   -->
  <!--  to the XML start and end tags of comments.                          -->
  <!--   author: Ashley M. Clark                                            -->
  <!-- CHANGELOG                                                            -->
  <!-- 2016-08-16: Ensured that elements could be commented out using the 
        aforementioned character map solution. ~Ashley                      -->
  
  <xsl:character-map name="comment-delimiters">
    <xsl:output-character character="&comment-start;" string="&lt;!--"/>
    <xsl:output-character character="&comment-end;" string="--&gt;"/>
    <xsl:output-character character="&commented-start;" string="&lt;!-\-"/>
    <xsl:output-character character="&commented-end;" string="-\-&gt;"/>
  </xsl:character-map>
  
  <xsl:template match="/" mode="#all">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="*" mode="#all">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="text() | @*" mode="#all">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="comment()" mode="#default">
    <xsl:copy/>
  </xsl:template>
  
  <!--  COMMENTS  -->
  
  <!-- If a comment is primed to gain an ancestor comment, make it a fake 
    comment a la oXygen. -->
  <xsl:template match="comment()" mode="escape">
    <xsl:text>&commented-start;</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>&commented-end;</xsl:text>
  </xsl:template>
  
  <!-- Place a comment around some XML. -->
  <xsl:template name="commentOut">
    <xsl:param name="unwantedNode" required="yes"/>
    <xsl:variable name="escapedNode">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()" mode="escape"/>
      </xsl:copy>
    </xsl:variable>
    <xsl:text>&comment-start;</xsl:text>
    <xsl:copy-of  select="$escapedNode"/>
    <xsl:text>&comment-end;</xsl:text>
  </xsl:template>
  
  <!-- Remove some XML from a comment. -->
  <!-- Note that this template may not be useful for nested comments! -->
  <xsl:template name="outComment">
    <xsl:param name="comment" required="yes" as="xs:string"/>
    
    <xsl:value-of disable-output-escaping="yes" select="$comment"/>
  </xsl:template>
</xsl:stylesheet>