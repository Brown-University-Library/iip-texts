<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:t="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs xd" version="2.0">

    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> April 5, 2019</xd:p>
            <xd:p><xd:b>Author:</xd:b> elli</xd:p>
            <xd:p>Stylesheet to export IIP information in turtle format so it can be ingested into
                Pelagios. </xd:p>d </xd:desc>
    </xd:doc>

    <xsl:output method="text"/>
    <xsl:strip-space elements="*"/>


    <xsl:variable name="inscriptions"
        select="collection('/Users/ellimylonas/Dropbox/IIP-Admin/iip-git/epidoc-files/?select=*.xml')"/>



    <xsl:template match="/">

        <!-- namespaces used below -->
        <xsl:text>
@prefix cnt: &lt;http://www.w3.org/2011/content#> . 
@prefix dcterms: &lt;http://purl.org/dc/terms/> .
@prefix foaf: &lt;http://xmlns.com/foaf/0.1/> .
@prefix oa: &lt;http://www.w3.org/ns/oa#> .
@prefix pelagios: &lt;http://pelagios.github.io/vocab/terms#> .
@prefix relations: &lt;http://pelagios.github.io/vocab/relations#> .
@prefix xsd: &lt;http://www.w3.org/2001/XMLSchema> .
        </xsl:text>

        <xsl:for-each select="$inscriptions">
            <xsl:variable name="pleiades-id"
                select="normalize-space(.//t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:history/t:origin/t:placeName/t:settlement/@ref)"/>

            <xsl:choose>
                <xsl:when test="not($pleiades-id)"/>
                <xsl:otherwise>
                    <xsl:text>
                        
        #-------- an object --------------
    </xsl:text>

                    <!-- Make variables for elements that we're going to re-use
          -->

                    <xsl:variable name="idno" select="t:TEI/@xml:id"/>
                    <xsl:variable name="region"
                        select="normalize-space(.//t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:history/t:origin/t:placeName/t:region)"/>
                    <xsl:variable name="city"
                        select="normalize-space(.//t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:history/t:origin/t:placeName/t:settlement/text())"/>
                    <xsl:variable name="date"
                        select="normalize-space(.//t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:history/t:origin/t:date)"/>
                    <xsl:variable name="date-notBefore"
                        select="normalize-space(.//t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:history/t:origin/t:date/@notBefore)"/>
                    <xsl:variable name="date-notAfter"
                        select="normalize-space(.//t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:history/t:origin/t:date/@notAfter)"/>
                    <xsl:variable name="periodo-id"
                        select="tokenize(.//t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:history/t:origin/t:date/@period)"/>
                    <xsl:variable name="genre"
                        select="tokenize(/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:msContents/t:msItem/@class, '\s')"/>
                    <xsl:variable name="object"
                        select="tokenize(/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:physDesc/t:objectDesc/@ana, '\s')"/>
                    <xsl:variable name="lang"
                        select="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:msContents/t:textLang/@mainLang"/>
                    <xsl:variable name="tmp-title">
                        <xsl:value-of select="upper-case($idno)"/>: <xsl:if
                            test="not(normalize-space($city) = '')">
                            <xsl:value-of select="$city"/>, </xsl:if>
                        <xsl:value-of select="$region"/>, <xsl:value-of select="$date"/>.
                            <xsl:for-each select="$genre">
                            <xsl:variable name="genreID" select="substring-after(., '#')"/>
                                <xsl:value-of
                                select="document('../include_taxonomies.xml')/t:classDecl/t:taxonomy/t:category[@xml:id = $genreID]/t:catDesc"/>
                            <xsl:if test="position() != last()">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                        </xsl:for-each>. <xsl:for-each select="$object">
                            <xsl:variable name="objectID" select="substring-after(., '#')"/>
                            <xsl:value-of
                                select="document('../include_taxonomies.xml')/t:classDecl/t:taxonomy/t:category[@xml:id = $objectID]/t:catDesc"/>
                            <xsl:if test="position() != last()">
                                <xsl:text>, </xsl:text>
                            </xsl:if>
                        </xsl:for-each>. </xsl:variable>
                    <xsl:variable name="title" select="normalize-space($tmp-title)"/>
                    <xsl:variable name="myNum" select="format-number(position(), '00000')"/>


                    <!-- start object doc -->
                    <!-- https://raw.githubusercontent.com/Brown-University-Library/iip-texts/master/pelagios/dump.ttl -->

                    <xsl:value-of
                        select="concat('&lt;https://raw.githubusercontent.com/Brown-University-Library/iip-texts/master/pelagios/dump.ttl#items/', $myNum, '>')"/>
                    <xsl:text>
    </xsl:text>
                    <xsl:text>a pelagios:AnnotatedThing ;
    </xsl:text>

                    <!-- generated title -->
                    <xsl:value-of select="concat('dcterms:title &quot;', $title, '&quot; ;')"/>

                    <!-- url of inscription -->
                    <xsl:text>
    </xsl:text>
                    <xsl:value-of
                        select="concat('foaf:homepage &lt;https://library.brown.edu/cds/projects/iip/viewinscr/', $idno, '> ;')"/>


                    <!-- Dates and periodo ID -->
                    <!-- add check that we have a first or second date... -->
                    <xsl:choose>
                        <xsl:when test="not($date-notBefore) and not($date-notAfter)"/>
                        <!-- no date -->
                        <xsl:when test="$date-notBefore and $date-notAfter">
                            <!-- full date -->
                            <xsl:text>
    </xsl:text>
                            <xsl:value-of
                                select="concat('dcterms:temporal &quot;', $date-notBefore, '/', $date-notAfter, '&quot; ;')"/>
                            <xsl:text>
    </xsl:text>
                            
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>
    </xsl:text>
                            <xsl:value-of
                                select="concat('dcterms:temporal ', $date-notBefore, $date-notAfter, ' ;')"/>
                            <xsl:text>
    </xsl:text>
                            
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:for-each select="$periodo-id">
                        <xsl:value-of
                            select="concat('dcterms:temporal &lt;', ., '> ;')"/>
                    </xsl:for-each>

                    <!-- language -->
                    <xsl:text>
    </xsl:text>
                    <xsl:value-of select="concat('dcterms:language &quot;', $lang, '&quot; ;')"/>

                    <!--annotation doc -->
                    <xsl:text>  
                .
                
    </xsl:text>
                    <xsl:value-of
                        select="concat('&lt;https://raw.githubusercontent.com/Brown-University-Library/iip-texts/master/pelagios/dump.ttl#items/', $myNum, '/annotations/01>')"/>
                    <xsl:text>
            
            a oa:Annotation ;
        </xsl:text>


                    <xsl:value-of
                        select="concat('oa:hasTarget &lt;https://raw.githubusercontent.com/Brown-University-Library/iip-texts/master/pelagios/dump.ttl#items/', $myNum, '>;')"/>
                    <xsl:text> 
    </xsl:text>
                    <xsl:value-of select="concat('oa:hasBody &lt;', $pleiades-id, '>  ;')"/>
                    <xsl:text>
                        .
                    </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

    </xsl:template>

</xsl:stylesheet>
