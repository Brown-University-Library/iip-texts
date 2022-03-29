<?xml version="1.0" encoding="UTF-8"?>

<!-- 2021-05-23 EM writes script to output CSV files in the following format: 
"FileID","Word Num","Normalized","Language","w/n/naw","Element" from IIP files that contain word segmentation information
Changes added: 
2021-05-24 Remove <foreign> and add the @xml:lang to the <w>
2021-05-25 Serialize XML element so it can be copied into the last field with escaped double quotes. 
2021-05-25 Copy @xml:lang attribute to <num> and <orig> from the containing <w>
2021-05-25 Remove commas from normalized words. 
-->


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd t"
    version="2.0">
    
    <xsl:output method="text" indent="no"/>
    <xsl:strip-space elements="*"/>
    
    
    <xsl:variable name="inscriptions"
        select="collection('/Users/emylonas/Projects/iip/2016XSLConversions/iip-git/scripts/word-segmentation/03HeaderMerged?select=*.xml')"/>
    
    <!-- it would be great to output a separate file for each language. one way might be using parameters. This raises the issue of 
    foreign words - does the code look at all the <w> elements? or just at the files that have each language code as their @mainLang?-->
    
    <xsl:template match="/">
    <xsl:text>"FileID","Word Num","Normalized","Language","w/n/naw","Element"
    </xsl:text>
        <!-- example element: <w xml:id="beth0043-1" xml:lang="grc">υἱὸς</w> -->
        
        <xsl:for-each select="$inscriptions">
            <xsl:variable name="file_id" select="t:TEI/@xml:id"/>
           
            <xsl:for-each select="//t:w| //t:num[ancestor::t:div[@subtype='transcription_segmented']] | //t:orig[ancestor::t:div[@subtype='transcription_segmented']][not(parent::t:choice)]">
               
                <xsl:variable name="whole-element">
                    <xsl:apply-templates select="." mode="stringify"/>
                </xsl:variable>
               
                <xsl:variable name="normalized">
                    <xsl:apply-templates mode="normalized-word"/>
                </xsl:variable>
                <xsl:value-of select="$file_id"/>,<xsl:value-of select="substring-after(@xml:id,'-')"/>,"<xsl:value-of select="replace($normalized,',','')"/>",<xsl:value-of select="@xml:lang"/>,<xsl:choose>
                    <xsl:when test="name(.) = 'w'">"w"</xsl:when>
                    <xsl:when test="name(.) = 'num'">"n"</xsl:when>
                    <xsl:when test="name(.) = 'orig'">"naw"</xsl:when>
                </xsl:choose>,"<xsl:value-of select="$whole-element" />"
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <!-- templates in normalized-word mode - take into account elements whose content should be ignored. 
        Otherwise copy text nodes.  -->
    
    <xsl:template match="t:expan" mode="normalized-word">
        <xsl:apply-templates mode="normalized-word"/>
    </xsl:template>
    
    <xsl:template match="t:abbr | t:ex" mode="normalized-word">
        <xsl:apply-templates mode="normalized-word"/>
    </xsl:template>
    
    <xsl:template match="t:am" mode="normalized-word"/>
    
    <xsl:template match="t:choice" mode="normalized-word">
        <xsl:apply-templates mode="normalized-word"/>
    </xsl:template>
    
    <xsl:template match="t:orig[parent::t:choice] | t:sic" mode="normalized-word"/>
    
    <xsl:template match="t:reg | t:corr" mode="normalized-word">
        <xsl:apply-templates mode="normalized-word"/>
    </xsl:template>
    
    <!-- templates in stringify mode - take the <w>, <num> or <orig> element that is being processed and copy all the markup and text
    into a string, so quotes can be escaped. This is for the last field in the CSV file-->
    
    <xsl:template match="*" mode="stringify">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:apply-templates select="@*" mode="stringify" />
        <xsl:choose>
            <xsl:when test="node()">
                <xsl:text>&gt;</xsl:text>
                <xsl:apply-templates mode="stringify" />
                <xsl:text>&lt;/</xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text>&gt;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> /&gt;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@*" mode="stringify">
        <xsl:text> </xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>=""</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>""</xsl:text>
    </xsl:template>
    
    <xsl:template match="text()" mode="stringify">
        <xsl:value-of select="."/>
    </xsl:template>
        
</xsl:stylesheet>