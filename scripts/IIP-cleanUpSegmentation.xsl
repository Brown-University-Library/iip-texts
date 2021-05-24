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
            <xd:p><xd:b>Created on:</xd:b> May 23, 2021</xd:p>
            <xd:p><xd:b>Author:</xd:b> elli</xd:p>
            <xd:p>Clean up script to follow on python word segmentation script. This script runs on an IIP Epidoc file that has a word segmentation div in it. It cleans up some of the following problems: 
            <xd:ul>
                <xd:li>removes w elements from around num and orig elements. </xd:li>
                <xd:li>removes foreign elements, and transfers their @xml:lang to the containing w element</xd:li>
                <xd:li>other things that we may run into. Possibly rejoin foreign phrases?</xd:li>
            </xd:ul> </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" indent="no" exclude-result-prefixes="xs xd t"/>
    
    <!-- <num> contained in <w> : remove <w> and copy @xml:id to <num> (don't forget that <num> already has attributes) -->
    
    <xsl:template match="t:w[child::t:num]">
        <xsl:element name="num" >
            <xsl:attribute name="xml:id" select="@xml:id"/>
            <xsl:if test="t:num[@value]">
                <xsl:attribute name="value" select="t:num/@value"/>
            </xsl:if>
            <xsl:copy-of select="t:num/node()" exclude-result-prefixes="#all" copy-namespaces="no"/>
        </xsl:element>
    </xsl:template>
    
    <!-- Same for <orig> as for <num>, but <orig> has no prior attributes. -->
    
    <xsl:template match="t:w[child::t:orig]">
        <xsl:element name="orig" >
            <xsl:attribute name="xml:id" select="@xml:id"/>
            <xsl:copy-of select="t:orig/node()" exclude-result-prefixes="#all" copy-namespaces="no"/>
        </xsl:element>
    </xsl:template>
    
    <!-- <foreign> inside <w> - remove <foreign>, make sure that the @xml:lang from <foreign> replaces the @xml:lang on <w> - 
          <w> already has an @xml:lang, but it reflects the surrounding text. -->
    
    <xsl:template match="t:w[child::t:foreign]">
        <xsl:element name="w">
            <xsl:attribute name="xml:id"><xsl:value-of select="@xml:id"/></xsl:attribute>
            <xsl:attribute name="xml:lang"><xsl:value-of select="t:foreign/@xml:lang"/></xsl:attribute>
            <xsl:copy-of select="t:foreign/node()" exclude-result-prefixes="#all" copy-namespaces="no"/>
        </xsl:element>
        
    </xsl:template>
    
    
   <!-- <xsl:template match="t:revisionDesc">
        <xsl:copy><xsl:apply-templates/>
            <t:change when="2021-05" who="persons.xml#Elli_Mylonas">Changed graphic element to facsimile and kept existing url</t:change>
        </xsl:copy>
    </xsl:template>-->
    
    
    <xsl:template match="@*|node()" >
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>