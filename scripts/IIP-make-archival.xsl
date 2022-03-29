<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd t"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b>Mar 12, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> elli</xd:p>
            <xd:p>Run script with following command: saxon -s:epidoc-files -xsl:make-archival.xsl -o:archival-files . (check paths of course)</xd:p>
            <            <xd:p>tThis script expects to find Zotero bibliography exported as TEI XML in a file called iip-zotero-export.xml which should be in the same 
                folder as the script (I think - need to check this). No need to have Zotero make xml:ids on export</xd:p>
        </xd:desc>
    </xd:doc>
    
    
    <xsl:output method="xml" version="1.1"/>
    
    <xsl:variable name="myID" select="/t:TEI/@xml:id"/>
    <xsl:variable name="settlement" select="t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:history/t:origin/t:placeName/t:settlement"/>
    <xsl:variable name="region" select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:history/t:origin/t:placeName/t:region"/>
    <xsl:variable name="date" select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:history/t:origin/t:date"/>
    <!-- attributes below can have multiple values -->
    <xsl:variable name="genre" select="tokenize(/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:msContents/t:msItem/@class, '\s')"/>
    <xsl:variable name="object" select="tokenize(/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:physDesc/t:objectDesc/@ana, '\s')"/>
    
    <xsl:template match="t:titleStmt">
       
        
       
        <xsl:element name="titleStmt" xml:space="preserve">
            <title><xsl:value-of select="upper-case($myID)"/>: <xsl:if test="not(normalize-space($settlement)='')">
                <xsl:value-of select="$settlement"/>, 
            </xsl:if>
                <xsl:value-of select="$region"/>, <xsl:value-of select="$date"/>.  
            <xsl:for-each select="$genre">
                <xsl:variable name="genreID" select="substring-after(.,'#')"/>
               
                <xsl:value-of select="document('include_taxonomies.xml')/t:classDecl/t:taxonomy/t:category[@xml:id=$genreID]/t:catDesc"/>
                <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>.
            <xsl:for-each select="$object">
                <xsl:variable name="objectID" select="substring-after(.,'#')"/>
                <xsl:value-of select="document('include_taxonomies.xml')/t:classDecl/t:taxonomy/t:category[@xml:id=$objectID]/t:catDesc"/>
                <xsl:if test="position() != last()">
                    <xsl:text>, </xsl:text>
                </xsl:if>
            </xsl:for-each>.</title>
        <principal>
            <persName xml:id="MS">Michael Satlow</persName>
        </principal>
        <respStmt>
            <resp>Project Manager</resp>
            <persName>Gaia Lembi</persName>
        </respStmt>
        <respStmt>
            <resp>Technical Oversight</resp>
            <persName>Elli Mylonas</persName>
        </respStmt>
    </xsl:element>
        <editionStmt>
            <edition n="v1">First archival edition <date>2019-03-15</date></edition>
        </editionStmt></xsl:template>
    
    <xsl:template match="t:publicationStmt">
        <publicationStmt>
            <authority>Brown University</authority>
            <idno type="IIP"><xsl:value-of select="$myID"/></idno>
            <availability status="free">
                <licence>This work is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License.
                    <ref target="http://creativecommons.org/licenses/by-nc/4.0/">Distributed under a Creative Commons licence Attribution-BY 4.0</ref>
                    <p>
                        All reuse or distribution of this work must contain somewhere a link to the DOI of the Inscriptions
                        of Israel/Palestine Project:
                        <ref>https://doi.org/10.26300/pz1d-st89</ref>
                    </p>
                </licence>
            </availability>
        </publicationStmt>
    </xsl:template>
    
    <xsl:template match="t:encodingDesc">
        <xsl:element name="encodingDesc" xml:space="preserve">
        <projectDesc>
            <p>The Inscriptions of Israel/Palestine project seeks to build an internet-accessible database of published inscriptions from Israel/Palestine dated ca. 500 BCE to 614 CE. This timespan roughly corresponds to the Persian, Greek, and Roman periods. Our database will make accessible the approximately 10,000 inscriptions published to date and will include substantial contextual information for these inscriptions, including images and geographic information. We tag our data according to Epidoc conventions. </p>
        </projectDesc>
       <classDecl>
           <taxonomy xml:id="IIP-form">
               <xsl:for-each select="$object">
                   <xsl:variable name="objectID" select="substring-after(.,'#')"/>
                   <xsl:copy-of select="document('include_taxonomies.xml')/t:classDecl/t:taxonomy/t:category[@xml:id=$objectID]"/>
              </xsl:for-each>
           </taxonomy>
           <taxonomy xml:id="IIP-materials">
               <xsl:for-each select="tokenize(/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:physDesc/t:objectDesc/t:supportDesc/@ana, '\s')">
                   <xsl:variable name="materialID" select="substring-after(.,'#')"/>
                   <xsl:copy-of select="document('include_taxonomies.xml')/t:classDecl/t:taxonomy/t:category[@xml:id=$materialID]"/>
               </xsl:for-each>
           </taxonomy>
           <taxonomy xml:id="IIP-genre">
               <xsl:for-each select="$genre">
                    <xsl:variable name="genreID" select="substring-after(.,'#')"/>
                   <!-- <xsl:copy-of select="document('../include_taxonomies.xml')/t:classDecl/t:taxonomy/t:category[@xml:id=$genreID]"/> -->
                    <xsl:copy-of select="document('include_taxonomies.xml')/t:classDecl/t:taxonomy/t:category[@xml:id=$genreID]"/>
               </xsl:for-each>
           </taxonomy>
            <taxonomy xml:id="IIP-preservation">
               <xsl:for-each select="tokenize(/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:physDesc/t:objectDesc/t:supportDesc/t:condition/@ana, '\s')">
                   <xsl:variable name="conditionID" select="substring-after(.,'#')"/>
                   <xsl:copy-of select="document('include_taxonomies.xml')/t:classDecl/t:taxonomy/t:category[@xml:id=$conditionID]"/>
               </xsl:for-each>
               
           </taxonomy>
           <taxonomy xml:id="IIP-writing">
               <xsl:for-each select="tokenize(/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:physDesc/t:handDesc/t:handNote/@ana, '\s')">
                   <xsl:variable name="writingID" select="substring-after(.,'#')"/>
                   <xsl:copy-of select="document('include_taxonomies.xml')/t:classDecl/t:taxonomy/t:category[@xml:id=$writingID]"/>
               </xsl:for-each>
           </taxonomy>
           <taxonomy xml:id="IIP-religion">
               <xsl:for-each select="tokenize(/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:msContents/t:msItem/@ana, '\s')">
                 <xsl:variable name="religionID" select="substring-after(.,'#')"/>
               <xsl:copy-of select="document('include_taxonomies.xml')/t:classDecl/t:taxonomy/t:category[@xml:id=$religionID]"/></xsl:for-each>
           </taxonomy>
       </classDecl>
        </xsl:element>
        
    </xsl:template>
   
     
    <xsl:template match="t:revisionDesc">
       
        <xsl:copy >
            <xsl:apply-templates/>
            <xsl:element name="change" namespace="http://www.tei-c.org/ns/1.0" >
                <xsl:attribute name="when">2019-03-12</xsl:attribute>
                <xsl:attribute name="who">persons.xml#Elli_Mylonas</xsl:attribute>
                Inserting new titleStmt and PubStmt info
            </xsl:element>
        </xsl:copy>
        
    </xsl:template>
    
    <xsl:template match="t:listBibl">
        <xsl:for-each select="t:bibl">
            <xsl:variable name="bibID" select="substring(t:ptr/@target,1,7)"/>
            <xsl:variable name="biblScopeUnit" select="t:biblScope/@unit"/>
            <xsl:variable name="biblScopeRef" select="t:biblScope"/>
            <xsl:element name="biblStruct" xml:space="preserve"><xsl:attribute name="n"><xsl:value-of select="$bibID"/></xsl:attribute><xsl:attribute name="xml:id" select="@xml:id"/>
                <xsl:copy-of select="document('iip-zotero-export.xml')//t:biblStruct[descendant::t:note[@xml:id = $bibID]]/t:analytic"/>
                <xsl:copy-of select="document('iip-zotero-export.xml')//t:biblStruct[descendant::t:note[@xml:id = $bibID]]/t:monogr"/>
                <citedRange unit="{$biblScopeUnit}"><xsl:value-of select="$biblScopeRef"/></citedRange>
            </xsl:element>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="@*|node()" >
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
