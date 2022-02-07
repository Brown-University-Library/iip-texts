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
            <xd:p><xd:b>Created on:</xd:b> January, 2022</xd:p>
            <xd:p><xd:b>Author:</xd:b> elli</xd:p>
            <xd:p>This script creates multiple files with only the transcription from IIP files, so they may be diffed.
                <xd:ul>
                    <xd:li></xd:li>
                    <xd:li></xd:li>
                    <xd:li></xd:li>
                </xd:ul> </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" exclude-result-prefixes="xs xd t"/>
    
    <xsl:variable name="this-inscription" select="/t:TEI/@xml:id"/>
    <xsl:variable name="filename-orig" select="concat('/Users/emylonas/Dropbox (Brown)/IIP Files/iip-git/epidoc-files/',$this-inscription,'.xml')"/>
    <xsl:variable name="filename-div-orig" select="concat('/Users/emylonas/Desktop/IIP-diff/transcription-orig/',$this-inscription,'.xml')"/>
    <xsl:variable name="filename-div-seg" select="concat('/Users/emylonas/Desktop/IIP-diff/transcription-seg/',$this-inscription,'.xml')"/>
    <xsl:variable name="filename-diff" select="concat('/Users/emylonas/Desktop/IIP-diff/',$this-inscription,'-diff.xml')"/>
    <xsl:variable name="filename-same" select="concat('/Users/emylonas/Desktop/IIP-diff/',$this-inscription,'-same.xml')"/>
    <!--<xsl:variable name="filename-seg" select="concat('/Users/emylonas/Desktop/IIPmerge/02cleaned-segmented-out',$this-inscription,'.xml')"/>-->
    
    
    
    <xsl:template match="t:body">
        <!--<xsl:choose>
        <xsl:when test="doc($filename-orig)/t:TEI//t:div[@subtype='transcription']/t:p = .">
            <xsl:result-document href="{$filename-diff}">
            not the same
            </xsl:result-document>    
        </xsl:when>
         <xsl:otherwise>
             <xsl:result-document href="{$filename-same}">
                  the same really
             </xsl:result-document>    
         </xsl:otherwise>
        </xsl:choose>-->
        
        <xsl:result-document href="{$filename-div-orig}">
            <xsl:copy-of select="doc($filename-orig)/t:TEI//t:div[@subtype='transcription']" copy-namespaces="no"/>
        </xsl:result-document>
        
        <xsl:result-document href="{$filename-div-seg}">
            <xsl:apply-templates select="t:div[@subtype='transcription']"/>
        </xsl:result-document>
        
    </xsl:template>
    
    <xsl:template match="@*|node()" >
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>