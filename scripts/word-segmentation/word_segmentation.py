#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
word_segmentation.py

Segment words from the XML files with <w> elements and export a CSV of words

DISCLAIMER - this is a prototype and not meant to be used in production


"""

import os
import glob
import re
import copy
import csv
import collections
from lxml import etree


# Local dependencies
from argument_parser import *


# Set the input and output paths
strPathIn = '.' + os.sep + 'word_segmentation_files_in'
strPathOut = '.' + os.sep + 'word_segmentation_files_out'
strPathListOut = '.' + os.sep + 'word_segmentation_lists'

# Get a list of all texts for processing
# Use command line arguments of the form "file1, file2, file3, etc." when given
# Otherwise, just use all files in the input directory
bClearFolder = False
vFilenames = ParseArguments()
if vFilenames is None:
	vTextFullPaths = glob.glob(strPathIn + os.sep + '*.xml')
	vTextFullPaths.sort()
	bClearFolder = True
else:
	vTextFullPaths = [strPathIn + os.sep + strFilename for strFilename in vFilenames]

vTextFullPaths.sort()

strTextsAll = ""
strExtraCharacters = ""

vNoLang = []
vLangs = []
vFoobarred = []

vAllowedLangs = [ 'arc', 'grc', 'he', 'la', 'x-unknown', 'syc', 'phn', 'xcl', 'Other', 'geo']
transformationErrors = 0




# Loop through the list of texts, parse XML, make data frames, save as CSV
for strTextFullPath in vTextFullPaths:

	# bypass the xxx inscriptions
	if "xxx" in strTextFullPath:
		continue

	# Extract the filename for the current text
	# Use the OS specific directory separator to split path and take the last element
	strTextFilename = strTextFullPath.split(os.sep)[-1]

	# Current parser options clean up redundant namespace declarations and remove patches of whitespace
	# For more info, see "Parser Options" in: https://lxml.de/parsing.html
	parser = etree.XMLParser(ns_clean=True, remove_blank_text=False)

	try:
		xmlText = etree.parse(strTextFullPath, parser)
	except Exception as e:
		print('#' * 20)
		print('Error with parsing text as XML:')
		print(e)
		print(strTextFilename)
		print('#' * 20)
		transformationErrors += 1
		continue

	nsmap = {'tei': "http://www.tei-c.org/ns/1.0"}

	ns = {'tei': "http://www.tei-c.org/ns/1.0"}
	TEI_NS = "{http://www.tei-c.org/ns/1.0}"
	XML_NS = "{http://www.w3.org/XML/1998/namespace}"
	textLang = xmlText.find('.//' + TEI_NS + 'textLang')

	# Get text-wide language settings
	strMainLanguage = ''
	try:
		strMainLanguage = textLang.attrib['mainLang']
	except:
		vNoLang.append(strTextFilename)
		strMainLanguage = 'grc'
		continue

	# Find cases where language code is wrong
	if strMainLanguage not in vAllowedLangs:
		print("Error, invalid language (%s) in %s" % (strMainLanguage, strTextFilename))
		continue


	vLangs.append(strMainLanguage)

	try:
		strOtherLanguages = textLang.attrib['otherLangs'].strip()
		if(len(strOtherLanguages) < 2):
			strOtherLanguages = None

	except:
		strOtherLanguages = None

    # test to see if there is a transcription div ?


	x = xmlText.findall(".//tei:div[@type='edition'][@subtype='transcription']//tei:p", namespaces=nsmap)

	# Skip it if the text has no textual content,
	if len(x) < 1:
		print('No content ' + strTextFilename)
		vFoobarred.append(strTextFilename)
		continue
		# this should copy the file without changing it.

	# Get script/language from attribute on <p> when it exists
	# Right now this is unused, according to TEI, defines script (which is already obvious)
	if XML_NS + 'lang' in x[0].attrib:
		strPLanguage = x[0].attrib[XML_NS + 'lang']

	try:
		words = []
		editionSegmented = copy.deepcopy(x[0])
		editionSegmented.clear()

		strXMLText = etree.tostring(x[0], encoding='utf8', method='xml').decode('utf-8')

		# add test for empty strXMLText and don't process if it's emtpy
		if not strXMLText or not len(strXMLText):
			continue

		# remove all <lb>s
		strXMLText = re.sub(r"<lb break=\"no\"(\s*)/>", "", strXMLText)
		strXMLText = re.sub(r"(\s*)<lb break=\"no\"(\s*)/>(\s*)", "", strXMLText)
		strXMLText = re.sub(r"<lb\s*/>", " ", strXMLText)

		# Just delete <note>...</note> right from the start. Shouldn't be there anyway.
		strXMLText = re.sub(r"<note>([^<]*?)</note>", "", strXMLText)

		# Discard a bunch of stuff that we don't really care about in this context
		strXMLText = re.sub(r"<([/]*)gap([/]*)>", " ", strXMLText)
		strXMLText = re.sub(r"<([/]*)gap ([^>]*?)>", " ", strXMLText)
		strXMLText = re.sub(r"<orgName>(.*?)</orgName>", "", strXMLText)
		strXMLText = re.sub(r"<([/]*)handShift([^>]*?)>", " ", strXMLText)
		strXMLText = re.sub(r"<space([^>]*?)>", " ", strXMLText)

		# replace every space inside pointy brackets with a bullet
		# make the w breaks
		# take every space and make it into a w
		# add begin w and end w
		# put back the spaces

		# Convert any amount of whitespace to a single space
		strXMLText = " ".join(strXMLText.split())

		# Convert all spaces within element tag definitions (<>) to bullets
		# Run multiple times to get all the spaces between attribute names
		# EM has tried to remove all newlines from start tags.
		# EM checked and we don't seem to have elements with more than three
		# attributes inside <p>.
		# EM has checked and there don't seem to be multivalued attributes in <p>
		strXMLText = re.sub(r"<(\w+)\s([^>]*)>", "<\\1•\\2>", strXMLText)
		strXMLText = re.sub(r"<([^>]*)\s([^>]*)>", "<\\1•\\2>", strXMLText)
		strXMLText = re.sub(r"<([^>]*)\s([^>]*)>", "<\\1•\\2>", strXMLText)

		#convert all spaces within element content in numbers to bullets as
		# well.
		# strXMLText = re.sub(r"<(num[^>]*>[^\s]+)\s+", "<\\1•", strXMLText)

		# Convert all whitespace in document to <w>s
		strXMLText = re.sub(r"\s+", "</w> <w>", strXMLText)

		# Add a start and end <w>
		strXMLText = re.sub(r'<p([^>]*[^/])>', '<p\\1><w>', strXMLText)
		strXMLText = re.sub(r"</p>", "</w></p>", strXMLText)

		# remove any empty ws
		strXMLText = re.sub(r"<w></w>", "", strXMLText)

		#remove <w>s that only contain punctuation
		strXMLText = re.sub(r"<w[^>]+>[.,]</w>", "", strXMLText)

		#remove <w> elements that contain only a <g> element.
		strXMLText = re.sub(r"<w><g[^/]+/></w>", "", strXMLText)
		strXMLText = re.sub(r"<w><[^>]+><g[^/]+/></[^>]+></w>", "", strXMLText)
		strXMLText = re.sub(r"<w><g[^>]+>[^<]+</g></w>", "", strXMLText)
		strXMLText = re.sub(r"<w><[^>]+><g[^>]+>[^<]+</g></[^>]+></w>", "", strXMLText)

		# Convert the bullets back to spaces
		strXMLText = strXMLText.replace("•", " ")

		# print(strXMLText)

		strXMLText = re.sub(r"§+", "§", strXMLText)
		strXMLText = re.sub(r"§", " ", strXMLText)

		editionSegmented = etree.XML(strXMLText, parser)
	except Exception as e:

		print('#' * 20)
		print('Error with parsing edition as XML:')
		print(e)
		print(strTextFullPath)
		print(strXMLText)
		print('#' * 20)

		transformationErrors += 1

		continue



	## all child nodes should have ids
	wordElems = editionSegmented.findall(".//tei:w", namespaces=nsmap)
	for i, wordElem in enumerate(wordElems):
		wordElem.attrib[XML_NS + 'id'] = '{}-{}'.format(os.path.splitext(strTextFilename)[0], i + 1)
		has_foreign_elem = False
		for child in wordElem:
			if child.tag == '{http://www.tei-c.org/ns/1.0}supplied' and XML_NS + 'lang' in child.attrib:
				wordElem.attrib[XML_NS + 'lang'] = child.attrib[XML_NS + 'lang']
				has_foreign_elem = True
		if not has_foreign_elem:
			wordElem.attrib[XML_NS + 'lang'] = strMainLanguage



	# make new transcription segmented element and append our segmented edition to that
	body = xmlText.find(".//tei:body", namespaces=nsmap)
	transcription = xmlText.find(".//tei:div[@type='edition'][@subtype='transcription']", namespaces=nsmap)
	transcriptionSegmented = copy.deepcopy(transcription)
	transcriptionSegmented.clear()
	transcriptionSegmented.attrib['type'] = "edition"
	transcriptionSegmented.attrib['subtype'] = "transcription_segmented"

	editionSegmented.tail = "\n"
	transcriptionSegmented.append(editionSegmented)
	transcriptionSegmented.tail = "\n"
	body.append(transcriptionSegmented)


	# Skip it if the text has no textual content,
	if len(x) < 1:
		# print('Error in ' + strTextFilename)
		vFoobarred.append(strTextFilename)
		continue

	xmlData = etree.tostring(xmlText, encoding='utf-8', pretty_print=False, xml_declaration=True)
	file = open(strPathOut + os.sep + strTextFilename, "wb")
	file.write(xmlData)

	# strXMLText = re.sub(r"<lb break=\"no\"(\s*)/>", "¶", strXMLText)

# Read all segmented files for processing word lists
vSegmentedTexts = glob.glob(strPathOut + os.sep + '*.xml')
vSegmentedTexts.sort()

WORD_LISTS = {}
WORD_COUNT = 0

# Loop through texts building lists
for strSegmentedTextFullPath in vSegmentedTexts:

	# Extract the filename for the current text
	# Use the OS specific directory separator to split path and take the last element
	strTextFilename = strSegmentedTextFullPath.split(os.sep)[-1]

	# Current parser options clean up redundant namespace declarations and remove patches of whitespace
	# For more info, see "Parser Options" in: https://lxml.de/parsing.html
	parser = etree.XMLParser(ns_clean=True, remove_blank_text=False)
	try:
		xmlText = etree.parse(strSegmentedTextFullPath, parser)
	except Exception as e:

		print('#' * 20)
		print('Error with building lists for XML:')
		print(e)
		print(strSegmentedTextFullPath)
		print('#' * 20)
		continue

	wordElems = xmlText.findall(".//tei:div[@type='edition'][@subtype='transcription_segmented']/tei:p/tei:w", namespaces=nsmap)
	WORD_COUNT += len(wordElems)

	# Build word lists by language
	for wordElem in wordElems:
		# serialize the word elems to text
		wordElemText = etree.tostring(wordElem, encoding='utf8', method='xml').decode('utf-8').strip()
		wordElemText = wordElemText.replace('xmlns="http://www.tei-c.org/ns/1.0"', "")
		wordElemText = wordElemText.replace('xmlns:xi="http://www.w3.org/2001/XInclude"', "")

		# check if <num> elem is in text (quick method)
		wordIsNum = 0
		if "<num" in wordElemText:
			wordIsNum = 1

		# add version to unique/alphabetize on
		normalized = ''.join(wordElem.itertext()).strip()

		if wordElemText and len(wordElemText):
			wordParams = wordElem.attrib[XML_NS + 'id'].split('-')
			text = "{}.xml".format(wordParams[0])
			wordNumber = wordParams[1]

			if wordElem.attrib[XML_NS + 'lang'] in WORD_LISTS:
				WORD_LISTS[wordElem.attrib[XML_NS + 'lang']].append([text, wordNumber, normalized, wordElem.attrib[XML_NS + 'lang'], wordIsNum, wordElemText])
			else:
				WORD_LISTS[wordElem.attrib[XML_NS + 'lang']] = [[text, wordNumber, normalized, wordElem.attrib[XML_NS + 'lang'], wordIsNum, wordElemText]]



# Write word lists to CSV files
# for lang in WORD_LISTS:
#
# 	# write to file
# 	with open(strPathListOut + '/word_list_{}.csv'.format(lang.lower()), 'w') as csvfile:
# 		csvwriter = csv.writer(csvfile)
# 		for word_row in WORD_LISTS[lang]:
# 			csvwriter.writerow(word_row)

print("#" * 20)
print("#" * 20)
print("Total word count:")
print(WORD_COUNT)
print("Transformation errors:")
print(transformationErrors)
print("#" * 20)
