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
            <xd:p><xd:b>Created on:</xd:b> Feb 4, 2022</xd:p>
            <xd:p><xd:b>Author:</xd:b> elli</xd:p>
            <xd:p>This script will add the lemma to each w element in the segmented transcription div, using the 
                <xd:ul>
                    <xd:li></xd:li>
                    <xd:li></xd:li>
                    <xd:li></xd:li>
                </xd:ul> </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output method="xml" exclude-result-prefixes="xs xd t"/>
    
</xsl:stylesheet>