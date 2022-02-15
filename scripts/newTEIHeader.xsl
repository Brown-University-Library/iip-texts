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
            <xd:p>This script will take two sets of IIP files and will create a new file that contains the teiHeader and facsimile elements from one set, 
                and the body from the other. Ultimately, it may create files that contain the edition div from both files, so they can be
                compared. This is the first step towards merging sets of files whose versions have diverged.
               </xd:p>
            <xd:p>It's set up to run using Saxon command 
                <xd:pre>saxon -s:03HeaderMerged -xsl:/Users/emylonas/Dropbox\ \(Brown\)/IIP\ Files/iip-git/scripts/newTEIHeader.xsl -o:03FacsMerged/ -xi:off</xd:pre>
            from the directory that contains the input and the output directories.
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:variable name="this-inscription" select="/t:TEI/@xml:id"/>
    <xsl:variable name="filename-orig" select="concat('/Users/emylonas/Dropbox (Brown)/IIP Files/iip-git/epidoc-files/',$this-inscription,'.xml')"/>
    
    
    <xsl:output method="xml" indent="no" exclude-result-prefixes="xs xd t"/>
    
    <xsl:template match="t:teiHeader">
        <xsl:copy-of select="doc($filename-orig)/t:TEI/t:teiHeader"/>
    </xsl:template>
    
    <xsl:template match="t:facsimile">
        <xsl:copy-of select="doc($filename-orig)/t:TEI/t:facsimile"/>
    </xsl:template>
   
    <xsl:template match="@*|node()" >
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>