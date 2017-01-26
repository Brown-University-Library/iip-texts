<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:tei="http://www.tei-c.org/ns/1.0">
  <!--<xsl:include href="reverse.xsl"/>-->
  <!-- This stylesheet transforms an epidoc-format IIP inscription into a set of fields for passing to Solr -->
  <!-- Create <add> element that contains a number of <doc> elements that have <field name='[name]'>[value]</field>'s for each inscription-->
  <xsl:template match="/">
    <xsl:element name="add">
      <xsl:apply-templates select="/tei:TEI"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="/tei:TEI">
    <xsl:element name="doc">
      <xsl:call-template name="inscription_id"/>
      <xsl:call-template name="place"/>
      <xsl:call-template name="placeMenu"/>
      <xsl:call-template name="place_found"/>
      <xsl:call-template name="notAfter"/>
      <xsl:call-template name="notBefore"/>
      <xsl:call-template name="type"/>
      <xsl:call-template name="language"/>
      <xsl:call-template name="religion"/>
      <xsl:call-template name="physical_type"/>
      <xsl:call-template name="figure"/>
      <xsl:call-template name="transcription"/>
      <xsl:call-template name="translation"/>
      <xsl:call-template name="diplomatic"/>
      <xsl:call-template name="dimensions"/>
      <xsl:call-template name="bibl"/>
      <xsl:call-template name="specificBibl_all"/>
      <!--<xsl:call-template name="biblDiplomatic"/>
      <xsl:call-template name="biblTranscription"/>
      <xsl:call-template name="biblTranslation"/>-->
      <xsl:call-template name="short_description"/>
      <xsl:call-template name="description"/>
<!--      <xsl:call-template name="image"/>-->
      
    </xsl:element>
  </xsl:template>

   <xsl:template name="inscription_id">
    <xsl:variable name="inscription_id" select="@xml:id"/>
    <xsl:element name="field">
      <xsl:attribute name="name">inscription_id</xsl:attribute>
      <xsl:value-of select="$inscription_id"/>
    </xsl:element>
  </xsl:template>

    <!-- DONE -->
  <xsl:template name="place">
    <xsl:choose>
      <xsl:when test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:placeName/tei:region">
        <xsl:variable name="placeRegion" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:placeName/tei:region"/>
        <xsl:element name="field">
          <xsl:attribute name="name">region</xsl:attribute>
          <xsl:value-of select="$placeRegion"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    <xsl:choose>

      <xsl:when test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:placeName/tei:settlement">
        <xsl:variable name="placecity" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:placeName/tei:settlement"/>
        <xsl:element name="field">
          <xsl:attribute name="name">city</xsl:attribute>
          <xsl:value-of select="$placecity"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

    <!-- DONE -->
  <xsl:template name="placeMenu">
    <xsl:element name="field">
      <xsl:attribute name="name">placeMenu</xsl:attribute>
      <xsl:choose>
        <xsl:when test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:placeName/tei:settlement != ''">
          <xsl:variable name="placeCity" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:placeName/tei:settlement"/>
          <xsl:value-of select="$placeCity"/>
          <xsl:call-template name="placeMenuRegion"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:element>
    <xsl:choose>
      <xsl:when test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:placeName/tei:region != ''">
        <xsl:variable name="placeRegion" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:placeName/tei:region"/>
        <xsl:element name="field">
          <xsl:attribute name="name">placeMenu</xsl:attribute>
          <xsl:value-of select="$placeRegion"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>
    <!-- DONE -->
  <xsl:template name="notAfter">
    <xsl:variable name="notAfter" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:date/@notAfter"/>
    <xsl:element name="field">
      <xsl:attribute name="name">notAfter</xsl:attribute>
      <xsl:value-of select="$notAfter"/>
    </xsl:element>
  </xsl:template>
    <!-- DONE -->
  <xsl:template name="notBefore">
    <xsl:variable name="notBefore" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:date/@notBefore"/>
    <xsl:element name="field">
      <xsl:attribute name="name">notBefore</xsl:attribute>
      <xsl:value-of select="$notBefore"/>
    </xsl:element>
  </xsl:template>

    <!-- DONE -->
  <xsl:template name="type">
    <xsl:variable name="type" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:msItem/@class"/>
    <xsl:element name="field">
      <xsl:attribute name="name">type</xsl:attribute>
      <xsl:value-of select="translate($type, '#', '')"/>
    </xsl:element>
  </xsl:template>
    <!-- DONE -->
  <xsl:template name="language">
    <xsl:variable name="lang" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:textLang/@mainLang"/>
    <xsl:if test="$lang">
    <xsl:element name="field">
      <xsl:attribute name="name">language</xsl:attribute>
      <xsl:value-of select="$lang"/>
    </xsl:element>
    <xsl:element name="field">
      <xsl:attribute name="name">language_display</xsl:attribute>
      <xsl:choose>
        <xsl:when test="$lang='la'"><xsl:text>Latin</xsl:text></xsl:when>
        <xsl:when test="$lang='he'"><xsl:text>Hebrew</xsl:text></xsl:when>
        <xsl:when test="$lang='hbo'"><xsl:text>Hebrew</xsl:text></xsl:when>
        <xsl:when test="$lang='grc'"><xsl:text>Greek</xsl:text></xsl:when>
        <xsl:when test="$lang='arc'"><xsl:text>Aramaic</xsl:text></xsl:when>
        <xsl:otherwise><xsl:value-of select="$lang"></xsl:value-of></xsl:otherwise>
      </xsl:choose>
      
    </xsl:element>
    </xsl:if>
    
    <xsl:if test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:textLang/@otherLangs">
      <xsl:variable name="otherlangs" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:textLang/@otherLangs"/>
      <xsl:for-each select="tokenize($otherlangs, '[ ]')">
         <xsl:element name="field">
           <xsl:attribute name="name">language</xsl:attribute>
           <xsl:value-of select="."/>
         </xsl:element>
        <xsl:element name="field">
          <xsl:attribute name="name">language_display</xsl:attribute>
          <xsl:choose>
            <xsl:when test=".='la'"><xsl:text>Latin</xsl:text></xsl:when>
            <xsl:when test=".='he'"><xsl:text>Hebrew</xsl:text></xsl:when>
            <xsl:when test=".='hbo'"><xsl:text>Hebrew</xsl:text></xsl:when>
            <xsl:when test=".='grc'"><xsl:text>Greek</xsl:text></xsl:when>
            <xsl:when test=".='arc'"><xsl:text>Aramaic</xsl:text></xsl:when>
            <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
          </xsl:choose>
          
        </xsl:element>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>
    <!-- DONE -->
  <xsl:template name="religion">
    <xsl:if test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:msItem/@ana">
    <xsl:variable name="religion" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:msItem/@ana"/>
    <xsl:for-each select="tokenize($religion, '[ ]')">
    <xsl:element name="field">
      <xsl:attribute name="name">religion</xsl:attribute>
      <xsl:value-of select="translate(., '#', '')"/>
    </xsl:element>
    </xsl:for-each>
    </xsl:if>
  </xsl:template>
    <!-- DONE -->
  <xsl:template name="physical_type">
    <xsl:variable name="p_d" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/@ana"/>
    <xsl:element name="field">
      <xsl:attribute name="name">physical_type</xsl:attribute>
      <xsl:value-of select="translate($p_d, '#', '')"/>
    </xsl:element>
  </xsl:template>
    <!-- DONE -->
  <xsl:template name="figure">
    <xsl:for-each select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:decoDesc/tei:decoNote">
      <xsl:variable name="desc" select="tei:ab/normalize-space()"/>
      <xsl:variable name="loc" select="tei:locus/normalize-space()"/>
      <xsl:if test="$desc!= ''">
        <xsl:element name="field">
          <xsl:attribute name="name">figure_desc</xsl:attribute>
          <xsl:value-of select="$desc"/>
        </xsl:element>
      </xsl:if>
      <xsl:if test="$loc != ''">
        <xsl:element name="field">
          <xsl:attribute name="name">figure</xsl:attribute>
          <xsl:value-of select="translate($desc, '#', '')"/> (<xsl:value-of select="$loc"/>)</xsl:element>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
    <!-- DONE -->
  <xsl:template name="place_found">
    <!-- Format:
    [settlement], [region]. [locus] in [site].
    [detail]
    
    e.g.
    Providence, RI. Back corner desk in Rockefeller Library 218.
    
    Zoora, Negev. cemetery in An Naq
    Negev. Zoora. Found by local inhabitants in the northwest corner of the Bronze
    Age, Byzantine and Islamic cemetery in the An Naq neighborhood south of
    the Wadi al-Hasa, probably in secondary use in later graves.
    
    -->
    <xsl:variable name="region" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:placeName/tei:region"/>
    <xsl:variable name="settlement" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:placeName/tei:settlement"/>
    <xsl:variable name="site" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:placeName/tei:geogName[@type='site']"/>
    <xsl:variable name="locus" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:placeName/tei:geogFeat[@type='locus']"/>
    <xsl:element name="field">
      <xsl:attribute name="name">place_found</xsl:attribute>
      <xsl:text>[</xsl:text>
      <xsl:choose>
        
        <xsl:when test="$region!='' and $settlement!=''">
          <xsl:value-of select="$settlement"/><xsl:text>, </xsl:text><xsl:value-of select="$region"/><xsl:text>. </xsl:text>
          <xsl:if test="$locus!=''"><xsl:value-of select="$locus"/><xsl:text> in </xsl:text></xsl:if>
          <xsl:if test="$site!=''"><xsl:value-of select="$site"/><xsl:text>. </xsl:text></xsl:if>
          <xsl:text>]
</xsl:text>
          <xsl:if test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:p">
            <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:p"/><xsl:text> 
</xsl:text>
          </xsl:if>
          <xsl:if test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:note">
            <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:note"/>
          </xsl:if>
        </xsl:when>

        <xsl:when test="$region!=''">
          <xsl:value-of select="$region"/>
          <xsl:if test="$settlement"><xsl:text> (</xsl:text><xsl:value-of select="$settlement"/><xsl:text>)</xsl:text></xsl:if><xsl:text>. &#10;</xsl:text>
          
          <xsl:if test="$locus!=''"><xsl:value-of select="$locus"/><xsl:text> in </xsl:text></xsl:if>
          <xsl:if test="$site!=''"><xsl:value-of select="$site"/><xsl:text>. </xsl:text></xsl:if>
          <xsl:text>]
</xsl:text>
          <xsl:if test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:p">
            <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:p"/>
            <xsl:text> 
</xsl:text>
          </xsl:if>
          <xsl:if test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:note">
            <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:note"/>
          </xsl:if>
        </xsl:when>
        
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$locus or $site or tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:p or tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:note">
              <xsl:if test="$locus!=''"><xsl:value-of select="$locus"/></xsl:if>
              <xsl:if test="$locus!='' and $site!=''"><xsl:text> in </xsl:text></xsl:if>
              <xsl:if test="$site!=''"><xsl:value-of select="$site"/><xsl:text>. </xsl:text></xsl:if>
              <xsl:text>]
</xsl:text>
              <xsl:if test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:p">
                <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:p"/>
                <xsl:text> 
</xsl:text>
              </xsl:if>
              <xsl:if test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:note">
                <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:note"/>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise><xsl:text>[No Location]</xsl:text></xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

    <!-- DONE -->
  <xsl:template name="dimensions">
    <xsl:element name="field">
      <xsl:attribute name="name">dimensions</xsl:attribute>
      <xsl:text>h: </xsl:text>
      <xsl:choose>
        <xsl:when test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions/tei:height/@quantity">
          <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions/tei:height/@quantity"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions/tei:height/@unit"/>
        </xsl:when>
        <xsl:when test="normalize-space(string(tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions/tei:height))">
          <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions/tei:height"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>N/A</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>; w: </xsl:text>
      <xsl:choose>
        <xsl:when test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions/tei:width/@quantity">
          <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions/tei:width/@quantity"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions/tei:width/@unit"/>
        </xsl:when>
        <xsl:when test="normalize-space(string(tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions/tei:width))">
          <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions/tei:width"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>N/A</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>; d: </xsl:text>
      <xsl:choose>
        <xsl:when test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions/tei:depth/@quantity">
          <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions/tei:depth/@quantity"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions/tei:depth/@unit"/>
        </xsl:when>
        <xsl:when test="normalize-space(string(tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions/tei:depth))">
          <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support/tei:dimensions/tei:depth"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>N/A</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>; let: </xsl:text>
      <xsl:choose>
        <xsl:when test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:dimensions[@type='letter']/height">
          <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:dimensions[@type='letter']/tei:height/@min"/>
          <xsl:text>-</xsl:text>
          <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:dimensions[@type='letter']/tei:height/@max"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:dimensions[@type='letter']/tei:height/@unit"></xsl:value-of>
        </xsl:when>
        <xsl:when test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:dimensions/@extent">
          <xsl:choose>
            <!-- When there's an @quantity, use only the quantity and the unit --> 
            <xsl:when test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:dimensions/@quantity">
              <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:dimensions/@quantity"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:dimensions/@unit"/>
            </xsl:when>
            <!-- When there's both @atLeast and @atMost, use both and the unit with a dash --> 
            <xsl:when test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:dimensions/@atMost">
              <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:dimensions/@atLeast"/>
              <xsl:text>-</xsl:text>
              <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:dimensions/@atMost"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:dimensions/@unit"/>
            </xsl:when>
            <!-- When there's an @atLeast, but no @atMost use only the atLeast and the unit --> 
            <xsl:otherwise>
              <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:dimensions/@atLeast"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:handDesc/tei:handNote/tei:dimensions/@unit"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>N/A</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
    <!-- DONE -->
  <xsl:template name="bibl">
    <xsl:for-each select="tei:text/tei:back/tei:div[@type='bibliography']/tei:listBibl/tei:bibl">
      <xsl:element name="field">
        <xsl:attribute name="name">bibl</xsl:attribute>
        <xsl:text/>
        <xsl:text>bibl=</xsl:text>
        <xsl:value-of select="tei:ptr/@target"/>
        <xsl:text>|nType=</xsl:text>
        <xsl:value-of select="tei:biblScope/@unit"/>
        <xsl:text>|n=</xsl:text>
        <xsl:value-of select="tei:biblScope"/>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>
  <xsl:template name="specificBibl_all">
    <xsl:variable name="diplomatic_ids" select="tokenize(tei:text/tei:body/tei:div[@subtype='diplomatic']/@ana, '[ ]')" />
    <xsl:variable name="transcription_ids" select="tokenize(tei:text/tei:body/tei:div[@subtype='transcription']/@ana, '[ ]')" />
    <xsl:variable name="translation_ids" select="tokenize(tei:text/tei:body/tei:div[@type='translation']/@ana, '[ ]')" />
    <xsl:variable name="commentary_ids" select="tokenize(tei:text/tei:body/tei:div[@type='commentary']/@ana, '[ ]')" />
    
    <xsl:call-template name="specificBibl">
      <xsl:with-param name="field_name" select="'biblDiplomatic'"/>
      <xsl:with-param name="id_list" select="$diplomatic_ids"/>
    </xsl:call-template>
    
    <xsl:call-template name="specificBibl">
      <xsl:with-param name="field_name" select="'biblTranscription'"/>
      <xsl:with-param name="id_list" select="$transcription_ids"/>
    </xsl:call-template>
    
    <xsl:call-template name="specificBibl">
      <xsl:with-param name="field_name" select="'biblTranslation'"/>
      <xsl:with-param name="id_list" select="$translation_ids"/>
    </xsl:call-template>
    
<!--    <xsl:call-template name="specificBibl">
      <xsl:with-param name="field_name" select="'biblCommentary'"/>
      <xsl:with-param name="id_list" select="$commentary_ids"/>
    </xsl:call-template>-->
  </xsl:template>
  
  <xsl:template name="specificBibl">
    <xsl:param name="field_name"/>
    <xsl:param name="id_list"/>
    <xsl:variable name="bibl_list" select="tei:text/tei:back/tei:div[@type='bibliography']/tei:listBibl"/>
    <xsl:for-each select="$id_list">
      <xsl:if test=".!='None' and .!='#None'">
      <xsl:element name="field">
        <xsl:attribute name="name"><xsl:value-of select="$field_name"/></xsl:attribute>
        <xsl:choose>
          <xsl:when test=".='#MS' or .='MS' or .='#MLS' or .='MLS'">
            <xsl:text>ms</xsl:text>
          </xsl:when>
          <xsl:when test="starts-with(., '#')">
            <xsl:variable name="trimmed_id" select="substring(., 2)"></xsl:variable>
            <xsl:text/>
            <xsl:text>bibl=</xsl:text>
            <xsl:value-of select="$bibl_list/tei:bibl[@xml:id=$trimmed_id]/tei:ptr/@target"/>
            <xsl:text>|nType=</xsl:text>
            <xsl:value-of select="$bibl_list/tei:bibl[@xml:id=$trimmed_id]/tei:biblScope/@unit"/>
            <xsl:text>|n=</xsl:text>
            <xsl:value-of select="$bibl_list/tei:bibl[@xml:id=$trimmed_id]/tei:biblScope"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text/>
            <xsl:variable name="id" select="."/>
            <xsl:text>bibl=</xsl:text>
            <xsl:value-of select="$bibl_list/tei:bibl[@xml:id=$id]/tei:ptr/@target"/>
            <xsl:text>|nType=</xsl:text>
            <xsl:value-of select="$bibl_list/tei:bibl[@xml:id=$id]/tei:biblScope/@unit"/>
            <xsl:text>|n=</xsl:text>
            <xsl:value-of select="$bibl_list/tei:bibl[@xml:id=$id]/tei:biblScope"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
<!--    <!-\- TODO -\->
  <xsl:template name="biblDiplomatic">
    <xsl:for-each select="text/back/div[@type='bibliography']/listBibl/bibl">
      <xsl:if test="@xml:id = ancestor::header/following-sibling::tei:text/tei:body/tei:div[@type='diplomatic']/@target">
        <xsl:element name="field">
          <xsl:attribute name="name">biblDiplomatic</xsl:attribute>
          <xsl:text>bibl=</xsl:text>
          <xsl:value-of select="@ref"/>
          <xsl:text>|nType=</xsl:text>
          <xsl:value-of select="@nType"/>
          <xsl:text>|n=</xsl:text>
          <xsl:value-of select="@n"/>
        </xsl:element>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>-->
<!--    <!-\- TODO -\->
  <xsl:template name="biblTranscription">
    <xsl:for-each select="header/fileDesc/sourceDesc/inscSource/bibl">
      <xsl:if test="@id = ancestor::header/following-sibling::tei:text/tei:body/tei:div[@type='transcription']/@target">
        <xsl:element name="field">
          <xsl:attribute name="name">biblTranscription</xsl:attribute>
          <xsl:text>bibl=</xsl:text>
          <xsl:value-of select="@ref"/>
          <xsl:text>|nType=</xsl:text>
          <xsl:value-of select="@nType"/>
          <xsl:text>|n=</xsl:text>
          <xsl:value-of select="@n"/>
        </xsl:element>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>-->
<!--    <!-\- TODO -\->
  <xsl:template name="biblTranslation">
    <xsl:for-each select="header/fileDesc/sourceDesc/inscSource/bibl">
      <xsl:if test="@id = ancestor::header/following-sibling::tei:text/tei:body/tei:div[@type='translation']/@target">
        <xsl:element name="field">
          <xsl:attribute name="name">biblTranslation</xsl:attribute>
          <xsl:text>bibl=</xsl:text>
          <xsl:value-of select="@ref"/>
          <xsl:text>|nType=</xsl:text>
          <xsl:value-of select="@nType"/>
          <xsl:text>|n=</xsl:text>
          <xsl:value-of select="@n"/>
        </xsl:element>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>-->

    <!-- DONE -->
  <xsl:template name="short_description">
    <xsl:variable name="short_desc" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msContents/tei:msItem/tei:p"/>
    <xsl:element name="field">
      <xsl:attribute name="name">short_description</xsl:attribute>
      <xsl:value-of select="$short_desc"/>
    </xsl:element>
  </xsl:template>
    <!-- DONE -->
  <xsl:template name="description">
    <xsl:variable name="desc" select="tei:text/tei:back/tei:div[@type='commentary']"/>
    <xsl:element name="field">
      <xsl:attribute name="name">description</xsl:attribute>
      <xsl:value-of select="$desc"/>
    </xsl:element>
  </xsl:template>
    <!-- DONE -->
  <!--Transcription formatting cannibalized from old search.xsl-->
  <xsl:template name="diplomatic">
    <xsl:element name="field">
      <xsl:attribute name="name">diplomatic</xsl:attribute>
      
        <xsl:choose>
          <xsl:when test="tei:text/tei:body/tei:div/@xml:lang='heb'">
<![CDATA[<span dir="rtl" class="rtl">]]></xsl:when>
          <xsl:otherwise><![CDATA[<span>]]></xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="tei:text/tei:body/tei:div[@subtype='diplomatic'] != ''">
            <xsl:apply-templates select="tei:text/tei:body/tei:div[@subtype='diplomatic']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>[no diplomatic]</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
<![CDATA[</span>]]>
      
    </xsl:element>
  </xsl:template>
    <!-- DONE -->
  <xsl:template name="transcription">
    <xsl:element name="field">
      <xsl:attribute name="name">transcription</xsl:attribute>
      
        <xsl:choose>
          <xsl:when test="tei:text/tei:body/tei:div/@xml:lang='heb'">
<![CDATA[<span dir="rtl" class="rtl">]]>
          </xsl:when>
          <xsl:otherwise><![CDATA[<span>]]></xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
<!--           <xsl:when test="tei:text/tei:body/tei:div[@subtype='simpleTranscription'] != ''">
            <xsl:apply-templates select="tei:text/tei:body/tei:div[@subtype='simpleTranscription']"/>
          </xsl:when> -->
          <xsl:when test="tei:text/tei:body/tei:div[@subtype='transcription'] != ''">
            <xsl:apply-templates select="tei:text/tei:body/tei:div[@subtype='transcription']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>[no transcription]</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
<![CDATA[</span>]]>
      
    </xsl:element>
    <xsl:element name="field">
      <xsl:attribute name="name">transcription_search</xsl:attribute>
      <xsl:choose>
        <xsl:when test="string-length(tei:text/tei:body/tei:div[@subtype='simpleTranscription']) != 0">
          <xsl:apply-templates select="tei:text/tei:body/tei:div[@subtype='simpleTranscription']" mode="search"/>
        </xsl:when>
        <xsl:when test="tei:text/tei:body/tei:div[@subtype='transcription']">
          <xsl:apply-templates select="tei:text/tei:body/tei:div[@subtype='transcription']" mode="search"/>
        </xsl:when>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
    <!-- DONE -->
  <xsl:template name="translation">
    <xsl:element name="field">
      <xsl:attribute name="name">translation</xsl:attribute>
      
        <xsl:choose>
          <xsl:when test="tei:text/tei:body/tei:div[@type='translation'] != ''">
            <xsl:apply-templates select="tei:text/tei:body/tei:div[@type='translation']/tei:p"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>[no translation]</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      
    </xsl:element>
    <xsl:element name="field">
      <xsl:attribute name="name">translation_search</xsl:attribute>
      <xsl:value-of select="tei:text/tei:body/tei:div[@type='translation']"/>
    </xsl:element>

  </xsl:template>
    <!-- TODO -->
  <xsl:template name="image">
    <xsl:if test="tei:header/tei:fileDesc/tei:sourceDesc/tei:images/tei:image/@id">
      <xsl:for-each select="tei:header/tei:fileDesc/tei:sourceDesc/tei:images/tei:image">
        <xsl:element name="field">
          <xsl:attribute name="name">image</xsl:attribute>
          <xsl:if test="substring(@id, 1, 2) ='i_' ">
            <xsl:value-of select="substring(@id,3)"/>
          </xsl:if>
        </xsl:element>
        <xsl:if test="tei:imgSource/tei:note">
          <xsl:element name="field">
            <xsl:attribute name="name">imageSource</xsl:attribute>
            <xsl:value-of select="tei:imgSource/tei:note"/>
          </xsl:element>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:choice" mode="search">
    <xsl:choose>
      <xsl:when test="tei:abbr">
        <xsl:apply-templates select="tei:abbr" mode="search"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="tei:expan" mode="search"/>
      </xsl:when>
      <xsl:when test="tei:sic">
        <xsl:apply-templates select="tei:sic" mode="search"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="tei:corr" mode="search"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="tei:lb" mode="search">
    <xsl:text></xsl:text>
  </xsl:template>  
    
  <xsl:template match="tei:note"> </xsl:template>

  <xsl:template match="tei:lb">
    <xsl:choose>
      <xsl:when test="@break='no'"><![CDATA[-<br/>]]></xsl:when>
      <xsl:otherwise><![CDATA[<br/>]]></xsl:otherwise>
    </xsl:choose></xsl:template>

  <xsl:template match="tei:span">
    <xsl:choose>
      <xsl:when test="tei:text/tei:body/tei:div/@xml:lang='heb'">
<![CDATA[<span dir="rtl" class="rtl">]]>
      </xsl:when>
      <xsl:otherwise><![CDATA[<span>]]></xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/><![CDATA[</span>]]></xsl:template>

  <xsl:template match="tei:unclear">
    <xsl:choose>
      <xsl:when test="* | text()"><![CDATA[<u>]]><xsl:apply-templates/><![CDATA[</u>]]></xsl:when>
      <xsl:otherwise><![CDATA[<u>]]><![CDATA[</u>]]></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:gap">
    <xsl:choose>
      <xsl:when test="@extent = '1'">
        <xsl:text>[-]</xsl:text>
      </xsl:when>
      <xsl:when test="@extent = '2'">
        <xsl:text>[--]</xsl:text>
      </xsl:when>
      <xsl:when test="@extent = '3'">
        <xsl:text>[---]</xsl:text>
      </xsl:when>
      <xsl:when test="@extent = '4'">
        <xsl:text>[----]</xsl:text>
      </xsl:when>
      <xsl:when test="@extent = '5'">
        <xsl:text>[-----]</xsl:text>
      </xsl:when>
      <xsl:when test="@extent = '6'">
        <xsl:text>[------]</xsl:text>
      </xsl:when>
      <xsl:when test="@extent = '7'">
        <xsl:text>[-------]</xsl:text>
      </xsl:when>
      <xsl:when test="@extent = '8'">
        <xsl:text>[--------]</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>[-----]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:add">
    <xsl:text>(</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="tei:del">
    <xsl:text>[[</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>]]</xsl:text>
  </xsl:template>

  <xsl:template match="tei:supplied">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>]</xsl:text>
  </xsl:template>
  
  <xsl:template match="tei:choice">
    <xsl:choose>
      <xsl:when test="tei:abbr">
        <xsl:apply-templates select="tei:expan"/>
      </xsl:when>
      <xsl:when test="tei:sic">
        <xsl:apply-templates select="tei:corr"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
<!--
  <xsl:template name="get-figures">
    <xsl:param name="figures"/>
    <xsl:for-each select="$figures">
      <xsl:value-of select="desc"/>
      <xsl:if test="string(loc) != ''">
        <xsl:text> ( </xsl:text>
        <xsl:value-of select="loc"/>
        <xsl:if test="position()!=last()">); </xsl:if>
        <xsl:if test="position()=last()">).</xsl:if>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>-->

  <!-- DONE -->
  <xsl:template name="placeMenuRegion">
    <xsl:choose>
      <xsl:when test="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:placeName/tei:region != ''">
        <xsl:variable name="placeRegion" select="tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:placeName/tei:region"/>
        <xsl:text>  (</xsl:text>
        <xsl:value-of select="$placeRegion"/>
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
