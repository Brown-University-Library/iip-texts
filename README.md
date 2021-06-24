# iip-texts
IIP inscriptions encoded in Epidoc XML and supporting files

## Contents
This repository has the XML files of the IIP collection, encoded using the [Epidoc](https://sourceforge.net/p/epidoc/wiki/Home/) schema. It also holds some other versions of the files and scripts needed for their transformations.
* epidoc-files directory: All the IIP inscriptions, in their most current form
* archival-files directory:  copy of the working directory with all dependencies removed. These files are the archival forms of the working files, and are ingested periodically into the Brown Digital Repository.
* pelagios directory: contains ttl files with information formatted in RDF that can be harvested by Pelagios
* scripts directory: various scripts used to generate the above and other formats. These include the script for creating archival copies, for generating Pelagios output, generate the solr xml format used in indexing. There are also two scripts used in word segmentation process (IIP-cleanupSegmentation.xsl and IIP-create-word-CSV.xsl).

The scripts directory also has a subdirectory `word-segmentation` that holds scripts and also data directories for the pipeline developed to add `<w>` elements indicating discrete words, to the files. For more information see the README file in that directory.

## How to use archival bib processor. 
run *python [xmlprocessor.py](https://github.com/Brown-University-Library/iip-texts/blob/master/xmlprocessor.py)* and the output files will be in archival-files. You may have to install some Python libraries, please run these two command seperately: pip install beautifulsoup4, pip install requests _check - think we don't use this_ 

## Other files
* include_taxonomies contains the controlled vocabularies used in IIP metadata
* solr-schema.xml is the template for the output used to provision solr
