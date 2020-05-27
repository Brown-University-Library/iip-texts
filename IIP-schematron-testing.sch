<?xml version="1.0" encoding="UTF-8"?>

<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process"
        xmlns:t="http://www.tei-c.org/ns/1.0">
        <sch:ns uri="http://www.tei-c.org/ns/1.0" prefix="t"
         xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
         xmlns:sqf="http://www.schematron-quickfix.com/validator/process" 
         xmlns:iso="http://purl.oclc.org/dsdl/schematron" 
         xmlns:oxy="http://www.oxygenxml.com/schematron/validation" 
         xmlns:xs="http://www.w3.org/2001/XMLSchema" 
         xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
            xmlns:saxon="http://saxon.sf.net/" 
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
            xmlns:xhtml="http://www.w3.org/1999/xhtml" 
            xmlns:t="http://www.tei-c.org/ns/1.0" 
            oxy:elementURI="file:/Users/ellimylonas/Projects/iip/2016XSLConversions/iip-git/IIP-schematron-testing.sch"/>
        
        
        <!--*******
    This provides validation for encoders while working on their transcriptions.Itis based on the work
    done by Scott DiGiulio for USEP. From his notes: 
    "The transcription-oriented are drawn from the sample schematron provided on the
    EpiDoc sourceforge, with several customizations for the US Epigraphy Project added, especially
    with respect to bibliography and metadata."
    **Change log:
      2018-10-27 EM copied from USEP and started customization for IIP 
    -->
        
        <!-- Variable declaration -->
       <!-- <sch:let name="region" value="/t:TEI/t:teiHeader/t:fileDesc/t:sourceDesc/t:msDesc/t:msIdentifier/t:region"/>-->
               
        <sch:pattern> 
            <sch:title>Test machine readable name</sch:title>
            <sch:rule context="/">
                <sch:assert diagnostics="docName" test=" contains(document-uri(/), /@xml:id)">Machine-Readable ID must match filename</sch:assert>
                <!-- I'm cheating here, just looking to see if the ID is in the fn. Usually people have 
            completely wrong ID so this will catch most of those -->
            </sch:rule>
        </sch:pattern>
    
       <sch:pattern>
           <sch:title>Letter height dimensions</sch:title>
           <sch:rule context="//t:dimensions[@type='letter']">
               <sch:report test="(@quantity and @atLeast and @atMost)">Conflict: Letter height dimensions should either @quantity or @atLeast and @atMost</sch:report>
               <sch:report test="(@atleast) and not(@atMost)">If the letter height has only one value, it should be @quantity not @atLeast</sch:report>
               
           </sch:rule>
       </sch:pattern>
        
        <sch:pattern>
            <sch:title>Test for empty genre</sch:title>
            <sch:rule context="//t:msContents">
                <sch:report test="//t:msItem[@class='#xx']">Every inscription must have a valid genre</sch:report>
            </sch:rule>
        </sch:pattern>
        
        <sch:pattern>
            <sch:title>Test for empty support material</sch:title>
            <sch:rule context="//t:physDesc">
                <sch:report test="//t:supportDesc[@ana='#xx']">Every inscription must have a valid material</sch:report>
            </sch:rule>
        </sch:pattern>
        
        <sch:pattern>
            <sch:title>Test for empty condition</sch:title>
            <sch:rule context="//t:physDesc/t:objectDesc/t:supportDesc/t:condition">
                <sch:report test="//t:condition[@ana='#xx']"></sch:report>
            </sch:rule>
        </sch:pattern>
        
        <sch:pattern>
            <sch:title>Test for multiple ps under supportDesc</sch:title>
            <sch:rule context="//t:physDesc">
                <sch:report test="//t:supportDesc/t:support/t:p[2]">Cannot have two p-elements contained under support</sch:report>
            </sch:rule>
        </sch:pattern>
        
        <sch:pattern>
            <sch:title>Test for empty objectDesc</sch:title>
            <sch:rule context="//t:physDesc">
                <sch:report test="//t:objectDesc[@ana='#xx']">Every entry must contain a valid object type</sch:report>
            </sch:rule>
        </sch:pattern>
        
        <sch:pattern>
            <sch:title>Test for empty handNote</sch:title>
            <sch:rule context="//t:physDesc/t:handDesc">
                <sch:report test="//t:handNote[@ana='#xx']">Every entry must contain a valid writing description; if unknown, mark as such</sch:report>
            </sch:rule>
        </sch:pattern>
        
        <sch:pattern>
            <sch:title>Test for empty date fields</sch:title>
            <sch:rule context="//t:history/t:origin">
                <sch:report test="//t:date='Date to be displayed'">Enter a date for the inscription</sch:report>
                <sch:report test="(//t:date[@notBefore='0001'] and //t:date[@notAfter='0002'])">Enter a range of dates for the inscription</sch:report>
            </sch:rule>
        </sch:pattern>
        
        <sch:pattern>
            <sch:title>Test for empty place names</sch:title>
            <sch:rule context="//t:history/t:origin">
                <sch:report test="t:placeName[@ref='xx']">Inscription must have a valid place ref (e.g. europe.italy.rome)</sch:report>
                <sch:report test="t:placeName='Detailed place name'">Inscription must have a location; if it is unknown, mark as such</sch:report>
            </sch:rule>
        </sch:pattern>
        
         <sch:pattern>
            <sch:title>Test for empty bibl</sch:title>
            <sch:rule context="//t:listBibl">
                <sch:report test="normalize-space(.)=''">Every entry must include bibliography, even if it is unpublished</sch:report>
                <sch:report test="t:bibl/t:ptr[@target='#xx']">Every entry must include a page or inscription number; use "unpub" for unpublished inscriptions</sch:report>           
            </sch:rule>
        </sch:pattern>
    
    <sch:pattern>
        <sch:title>Test for empty unclear</sch:title>
        <sch:rule context="//t:unclear">
            <sch:report test="normalize-space(child::node())">unclear cannot be an empty element</sch:report>
        </sch:rule>
    </sch:pattern>
        
        <sch:pattern>
            <sch:title>Test for change log attribution</sch:title>
            <sch:rule context="//t:revisionDesc">
                <sch:report test="t:change[@who='xx']">Input your name in the change log</sch:report>
            </sch:rule>
        </sch:pattern>
        
   
     <!--   <sch:pattern>
            <sch:title>Image name test</sch:title>
            <sch:rule context="//t:facsimile">
                <sch:report test="starts-with(//t:graphic[@url], //t:publicationStmt/idno[@xml:id])">Image names should match the USEP ID (unless the image is a detail or alternate view, or the image is external)</sch:report>
            </sch:rule>
        </sch:pattern>-->
        
      <!--   <sch:pattern>
            <sch:title>Test for image formatting</sch:title>
            <sch:rule context="//t:facsimile">
                <sch:report test="//t:surface/t:graphic[2]">Each image must have its own surface element; do not put multiple graphic elements under the same surface</sch:report>            
            </sch:rule>
        </sch:pattern>-->
        
        <sch:pattern>
            <sch:title>Test gap attributes</sch:title>
            <sch:rule context="//t:gap">
                <sch:report test="(@extent and @quantity)">Conflict: @quantity and @extent both present on gap</sch:report>
                <sch:report test="(@reason='lost' or @reason='omitted') and not(@extent or @quantity or (@atLeast and @atMost))">gap needs one of @extent, @quantity or both @atLeast and @atMost</sch:report>
                <sch:report test="(@reason='lost' or @reason='omitted') and not(@unit)">Gap -  lost or omitted needs @unit</sch:report>
            </sch:rule>
        </sch:pattern>
        
        <sch:pattern>
            <sch:title>Test space attributes</sch:title>
            <sch:rule context="//t:space">
                <sch:report test="(@extent and @quantity)">conflict: @quantity and @extent both present on space</sch:report>
                <sch:report test="(@reason='lost' or @reason='omitted') and not(@extent or @quantity or (@atleast and @atMost))">space needs one of @extent, @quantity or both @atLeast and @atMost</sch:report>
                <sch:report test="(@reason='lost' or @reason='omitted') and not(@unit)">space - lost or omitted needs @unit</sch:report>
            </sch:rule>
        </sch:pattern>
 
        <sch:pattern>
            <sch:title>Check for gaps in supplied</sch:title>
            <sch:rule context="//t:div[@type='edition']//t:gap[not(@reason='ellipsis')]">
                <sch:report test="ancestor::t:supplied[not(@reason='undefined')]">Supplied may not contain gap</sch:report>
            </sch:rule>
        </sch:pattern>
       
        <sch:pattern>
            <sch:title>Checking for Leiden sigla</sch:title>
            <!-- the regexes below will only work if you have Schematron set to XPATH version 2.0 in your local environment -->
            <!-- in Oxygen: Options > Preferences > XML > XML Parser > Schematron -->
            <sch:rule context="//t:div[@type='edition']">
                <sch:report test="descendant::text()[not(ancestor::t:desc or ancestor::t:note)][matches(.,'[\[\]\(\)]')]">Brackets and parentheses in epigraphic text</sch:report>
                <sch:report test="descendant::text()[not(ancestor::t:desc or ancestor::t:note)][matches(.,'&#x0323;|&#xE1C0;')]">Underdots in epigraphic text</sch:report>
                <sch:report test="descendant::text()[not(ancestor::t:desc or ancestor::t:note)][matches(.,'&lt;|&gt;')]">Angle brackets in epigraphic text</sch:report>
            </sch:rule>
        </sch:pattern>
        
      <!--  <sch:pattern>
            <sch:title>Check for untagged words</sch:title>
            <sch:rule context="//t:div[@type='edition']">
                <sch:report test="descendant::text()[not(ancestor::t:w or ancestor::t:name or ancestor::t:placeName or ancestor::t:geogName or ancestor::t:num or ancestor::t:surplus
                    or ancestor::t:orig or ancestor::t:desc or ancestor::t:note or ancestor::t:head or ancestor::t:g or ancestor::t:abbr[not(ancestor::t:expan)])][not(translate(normalize-space(translate(.,',.;··:','')),' ','')='')]">
                    Character content needs to be tagged as word or name or number or undefined etc.
                </sch:report>
            </sch:rule>
        </sch:pattern>-->
        
        <sch:pattern>
            <sch:title>Check for problems with names and persnames</sch:title>
            <sch:rule context="//t:div[@type='edition']//t:name">
                <sch:report test="not(ancestor::t:persName or ancestor::t:placeName)">name needs to be inside persName or placeName</sch:report>
            </sch:rule>
            <sch:rule context="//t:div[@type='edition']//t:persName">
                <sch:report test="not(@type=('divine','emperor','ruler','consul','attested','other'))">persName @type needs to be one of 'divine','emperor','ruler',consul','attested','other'</sch:report>
            </sch:rule>
        </sch:pattern>
        
        <sch:pattern>
            <sch:title>Problems with abbreviations/expansions</sch:title>
            <sch:rule context="//t:ex">
                <sch:report test="not(ancestor::t:expan)">ex should only appear inside expan</sch:report>
                <sch:report test="parent::t:abbr">ex should not be a child of abbr</sch:report>
            </sch:rule>
            <sch:rule context="//t:expan">
                <!--<report test="not(descendant::t:ex)">expan should contain ex</report><-->
                <sch:report test="descendant::text()[not(translate(normalize-space(.),' ','')='')][not(ancestor::t:ex or ancestor::t:abbr)]">all text in expan should be in abbr or ex</sch:report>
            </sch:rule>  
            <sch:rule context="//t:expan">
                <!--<report test="not(descendant::t:ex)">expan should contain ex</report><-->
                <sch:report test="child::t:am">am should not be a child of expan.</sch:report>
            </sch:rule> 
        </sch:pattern>
        
        <sch:diagnostics>
            <sch:diagnostic id="docName">
                <sch:value-of select="substring-before(document-uri(/), '.xml')"/>
            </sch:diagnostic>
        </sch:diagnostics>
    </sch:schema>