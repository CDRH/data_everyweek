<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0"
  exclude-result-prefixes="xsl tei xs">

  <!-- ==================================================================== -->
  <!--                             IMPORTS                                  -->
  <!-- ==================================================================== -->

  <xsl:import href="../.xslt-datura/tei_to_html/tei_to_html.xsl"/>

  <!-- To override, copy this file into your collection's script directory
    and change the above paths to:
    "../../.xslt-datura/tei_to_html/lib/formatting.xsl"
 -->

  <!-- For display in TEI framework, have changed all namespace declarations to http://www.tei-c.org/ns/1.0. If different (e.g. Whitman), will need to change -->
  <xsl:output method="xml" indent="no" encoding="UTF-8" omit-xml-declaration="yes"/>


  <!-- ==================================================================== -->
  <!--                           PARAMETERS                                 -->
  <!-- ==================================================================== -->

  <xsl:param name="collection"/>
  <xsl:param name="data_base"/>
  <xsl:param name="environment"/>
  <xsl:param name="image_large"/>
  <xsl:param name="image_thumb"/>
  <xsl:param name="image_illustration"/>
  <xsl:param name="media_base"/>
  <xsl:param name="site_url"/>
  
  <xsl:variable name="newline" select="'&#x0A;'"/>
  <xsl:variable name="title" select="//teiHeader//titleStmt//title[1]"/>
  <xsl:variable name="category" select="//teiHeader//encodingDesc//catDesc[1]"/>
  <xsl:variable name="pubDate" select="//teiHeader//bibl/date/@when"/>
  <xsl:variable name="document" select="tokenize(base-uri(.),'/')[last()]"/>
  
  <xsl:variable name="liquid_var">{{ base_url | relative_url }}</xsl:variable>

  <!-- ==================================================================== -->
  <!--                            OVERRIDES                                 -->
  <!-- ==================================================================== -->
  
  <!-- Create front matter (YML) header -->
  <xsl:template match="/">
    <xsl:text>---</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:text>title: </xsl:text><xsl:value-of select="$title"/>
    <xsl:value-of select="$newline"/>
    <xsl:text>document: </xsl:text><xsl:value-of select="$document"/>
    <xsl:value-of select="$newline"/>
    <!-- author should be an array because there are multiple values -->
    <xsl:text>author: [</xsl:text>
    <xsl:for-each select="//persName[@type='author'][@key]">
      <xsl:variable name="authorName">
        <xsl:choose>
          <xsl:when test="contains(./@key,'#')"><xsl:value-of select="substring-after(./@key,'#')"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="./@key"/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="count" select="count(following::persName[@type='author'])"/>
      <xsl:choose>
        <xsl:when test="./@key = preceding::persName[@type='author']/@key"/>
        <xsl:otherwise>
          <xsl:text>"</xsl:text><xsl:value-of select="$authorName"/><xsl:text>"</xsl:text>
          <xsl:if test="$count != 0">
            <xsl:if test="following::persName[@type='author'][@key != preceding::persName[@type='author']/@key]"><xsl:text>,</xsl:text></xsl:if>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <xsl:text>]</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:text>publication_date: </xsl:text><xsl:value-of select="$pubDate"/>
    <xsl:value-of select="$newline"/>
    <!--<xsl:text>category: </xsl:text><xsl:value-of select="$category"/>-->
    <xsl:text>category: periodical</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:text>---</xsl:text>
    <xsl:value-of select="$newline"/>
    <xsl:value-of select="$newline"/>
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="text">
    <div class="issue">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="titlePage">
    <table>
      <tr>
        <td>
          <h2 data-pagefind-weight="2"><xsl:apply-templates select="docTitle"/></h2>
          <xsl:value-of select="$newline"/>
          <xsl:apply-templates select="docEdition"/>
          <h6><xsl:apply-templates select="descendant::publisher"/></h6>
          <h6><i><xsl:apply-templates select="descendant::pubPlace"/></i></h6>
          <xsl:if test="descendant::docDate"><h6>© <xsl:apply-templates select="descendant::docDate"/></h6></xsl:if>
        </td>
      </tr>
    </table>
  </xsl:template>
  
  <xsl:template match="pb">
    <xsl:variable name="img_name"><xsl:value-of select="@xml:id"/></xsl:variable>
    <xsl:variable name="img_alt"><xsl:value-of select="@n"/></xsl:variable>
    <hr class="pb"/>
    <div class="page_number page_image">
      <a href="{$liquid_var}/assets/images/large/{$img_name}.jpg">
        <img class="thumbnail" alt="{$img_alt}" src="{$liquid_var}/assets/images/small/{$img_name}.jpg"/>
      </a>
    </div>
  </xsl:template>
  
  <xsl:template match="figure">
    <div class="ew_figure">
      <p>[<xsl:value-of select="@n"/>]</p>
      
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="head">
    <xsl:choose>
      <xsl:when test="@type='main'"><h2><xsl:apply-templates/></h2></xsl:when>
      <xsl:when test="ancestor::figure"><h4><xsl:apply-templates/></h4></xsl:when>
      <xsl:otherwise><h3><xsl:apply-templates/></h3></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="hi[@rend='initialcap']">
    <em><xsl:apply-templates/></em>
  </xsl:template>
  
  <xsl:template match="quote">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="byline">
    <p><xsl:apply-templates/></p>
  </xsl:template>
  
  <xsl:template match="note[@place='margin-bot']"/>
  
  <xsl:template match="text[@xml:id]">
    <xsl:variable name="jump_id" select="@xml:id"/>
    <div id="{$jump_id}"><xsl:apply-templates/></div>
  </xsl:template>
  
  <xsl:template match="*[local-name()='ref']">
    <xsl:variable name="top_docdate">
      <xsl:value-of select="substring-after(/TEI/@xml:id,'ew.issue.')"/>
    </xsl:variable>
    
    <xsl:variable name="local_docdate">
      <xsl:choose>
        <xsl:when test="contains(@target,'.jump')">
          <xsl:value-of select="substring-before(substring-after(@target,'.'),'.jump')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-after(@target,'.')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:choose>
      <xsl:when test="$local_docdate != $top_docdate">
        <a href="ew.issue.{$local_docdate}.html#{@target}"><xsl:apply-templates/></a>
      </xsl:when>
      <xsl:when test="contains(@target,'#')">
        <a href="@target"><xsl:apply-templates/></a>
      </xsl:when>
      <xsl:otherwise>
        <a href="#{@target}"><xsl:apply-templates/></a>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- keeping for reference for now, but this is probably a TEI fix -->
  <!--<xsl:template match="p[@rend='jumpline']/ref">
    <xsl:variable name="jump_id" select="concat('#',@target)"/>
    <xsl:variable name="unjumped_id" select="concat('#',substring-before(@target,'.jump'))"/>
    <xsl:choose>
      <xsl:when test="contains(ancestor::text/@xml:id,'jump')"><a href="{$unjumped_id}" class="internal_link"><xsl:apply-templates/></a></xsl:when>
      <xsl:otherwise><a href="{$jump_id}" class="internal_link"><xsl:apply-templates/></a></xsl:otherwise>
    </xsl:choose>
  </xsl:template>-->
  
</xsl:stylesheet>
