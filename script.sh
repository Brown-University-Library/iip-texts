iip file name format    \w[4]\d[4]\w*.xml
saxon -s:epidoc-files/beth0007.xml -xsl:/Users/ellimylonas/Projects/iip/2016XSLConversions/xsl/make-archival.xsl -o:outputAddPeriodo/beth0007.xml

-s is source file, -xsl is xsl script -o is output. script is make-archival.xsl and will be in git root