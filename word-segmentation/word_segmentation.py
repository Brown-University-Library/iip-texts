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
import sys
import datetime

try:
	from lxml import etree
except Exception as e:
	print(f"\nERROR: {e}")
	print("\nRunning this script requires the lxml module. You can run the below command in the command line to install it:")
	print("----------------")
	print("pip install lxml")
	print("----------------")
	sys.exit()


# Function to remove element without losing tail text, if present.
# Function either attaches tail text of removed element to tail
# text of previous element, if extant, or adds it to the text of
# the parent element.
# From https://github.com/OaklandPeters/til/blob/master/til/python/lxml-and-tail-text.md
def remove_element(elem):
	parent = elem.getparent()
	if elem.tail:
		prev = elem.getprevious()
		if prev is not None:
			if prev.tail:
				prev.tail += elem.tail
			else:
				prev.tail = elem.tail
		else:
			if parent.text:
				parent.text += elem.tail
			else:
				parent.text = elem.tail
	parent.remove(elem)


# Local dependencies
from argument_parser import *


# Set the input and output paths
strPathIn =  '00unsegmented'
strPathOut = '.' + os.sep + '01python_segmentation_out'
strPathListOut = '.' + os.sep + 'word_segmentation_lists'

if not os.path.exists(strPathOut):
	os.makedirs(strPathOut)
if not os.path.exists(strPathListOut):
	os.makedirs(strPathListOut)

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

	#CR: strip exterior whitespace (usually newlines) in choice elements
	choices = x[0].findall(".//tei:choice", namespaces=nsmap)
	for choice in choices:
		if choice.text != None:
			choice.text = choice.text.strip()
		for child in choice.getchildren():
			if child.text != None:
				child.text = child.text.strip()
			if child.tail != None:
				child.tail = child.tail.strip()

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
		#CR: added regex line to handle empty <del>s is below
		strXMLText = re.sub(r"<([/]*)del ([^>]*?)>(\s*)</del>", "", strXMLText)
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

		# Convert all whitespace in document to <w>s
		strXMLText = re.sub(r"\s+", "</w> <w>", strXMLText)

		# Add a start and end <w>
		strXMLText = re.sub(r'<p([^>]*[^/])>', '<p\\1><w>', strXMLText)
		strXMLText = re.sub(r"</p>", "</w></p>", strXMLText)

		# remove any empty ws
		strXMLText = re.sub(r"<w></w>", "", strXMLText)

		#remove <w>s that only contain punctuation
		strXMLText = re.sub(r"<w>[.,]</w>", "", strXMLText)

		#remove <w> elements that contain only a <g> element.
		strXMLText = re.sub(r"<w><g[^/]+/></w>", "", strXMLText)
		strXMLText = re.sub(r"<w><[^>]+><g[^/]+/></[^>]+></w>", "", strXMLText)
		strXMLText = re.sub(r"<w><g[^>]+>[^<]+</g></w>", "", strXMLText)
		strXMLText = re.sub(r"<w><[^>]+><g[^>]+>[^<]+</g></[^>]+></w>", "", strXMLText)
		strXMLText = re.sub(r"<w><g>[^<]+</g></w>", "", strXMLText)

		#CR: remove figure elements
		strXMLText = re.sub(r"<figure>(.*?)</figure>", "", strXMLText)
		
		#CR: handle extra whitespace
		while re.search(r'  ',strXMLText):
			strXMLText = re.sub(r'  ',' ',strXMLText)

		# Convert the bullets back to spaces
		strXMLText = strXMLText.replace("•", " ")

		# print(strXMLText)

		strXMLText = re.sub(r"§+", "§", strXMLText)
		strXMLText = re.sub(r"§", " ", strXMLText)


		#CR: looking at bilingual cases
		if 'foreign' in strXMLText:
			if '<w><foreign' not in strXMLText:
				pass
			res = re.finditer(r'<foreign[\w\W]*?<\/foreign>', strXMLText)
			
			newstring = ""
			nonMatchStart = 0
			for match in res:
				if nonMatchStart != match.start():
					substring = strXMLText[nonMatchStart:match.start()]
					newstring = newstring + substring
				foreign = re.search(r'<foreign[^>]*?>', match.group())
				substring = re.sub(r"</w>", "</foreign></w>", match.group())
				substring = re.sub(r'<w>','<w>'+foreign.group(),substring)
				substring = re.sub(r'<foreign[^>]*?></foreign>',"", substring)
				newstring = newstring+substring
				nonMatchStart = match.end()
			substring = strXMLText[nonMatchStart:]
			newstring = newstring+substring
			newstring.strip()
			strXMLText = newstring
			# remove any empty ws again
			strXMLText = re.sub(r"<w></w>", "", strXMLText)


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
		for desc in wordElem.iterdescendants():
			#CR: correcting code to handle foreign tags.
			# lang attribute now moved correctly; foreign tag stripped out after.
			if desc.tag == '{http://www.tei-c.org/ns/1.0}foreign' and XML_NS + 'lang' in desc.attrib:
				has_foreign_elem = True
				wordElem.attrib[XML_NS + 'lang'] = desc.attrib[XML_NS + 'lang']
				has_foreign_elem = True
				etree.strip_tags(wordElem, '{http://www.tei-c.org/ns/1.0}foreign')
		if not has_foreign_elem:
			wordElem.attrib[XML_NS + 'lang'] = strMainLanguage

		#CR: handle num and orig elements
		for num in wordElem.xpath(".//tei:num", namespaces=nsmap):
			for at in num.attrib:
				wordElem.attrib[at] = num.attrib[at]
			wordElem.tag = num.tag
			etree.strip_tags(wordElem, '{http://www.tei-c.org/ns/1.0}num')
		for orig in wordElem.xpath('.//tei:orig[not(ancestor::tei:choice)]', namespaces=nsmap):
			wordElem.tag = orig.tag
			etree.strip_tags(wordElem, '{http://www.tei-c.org/ns/1.0}orig')




	# make new transcription segmented element and append our segmented edition to that
	body = xmlText.find(".//tei:body", namespaces=nsmap)
	transcription = xmlText.find(".//tei:div[@type='edition'][@subtype='transcription']", namespaces=nsmap)
	transcriptionSegmented = copy.deepcopy(transcription)
	transcriptionSegmented.clear()
	transcriptionSegmented.attrib['type'] = "edition"
	transcriptionSegmented.attrib['subtype'] = "transcription_segmented"
	#CR: adding change attribute to div with date of segmentation
	date = datetime.datetime.now().strftime("%Y-%m-%d")
	transcriptionSegmented.attrib['change'] = f"c{date}"

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
w_naw_num = {'{http://www.tei-c.org/ns/1.0}w':'w',
			 '{http://www.tei-c.org/ns/1.0}num':'n',
			 '{http://www.tei-c.org/ns/1.0}orig':'naw'}

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

	#CR: changing this to accept w, num, and orig elems
	wordElems = xmlText.findall(".//tei:div[@type='edition'][@subtype='transcription_segmented']//tei:p/*", namespaces=nsmap)
	WORD_COUNT += len(wordElems)

	# Build word lists by language
	for wordElem in wordElems:
		#CR: handle things like choice elements, abbreviation marks, glyphs, surplus text
		wordElemNorm = copy.deepcopy(wordElem)
		for sic in wordElemNorm.xpath(".//tei:choice//tei:sic", namespaces=nsmap):
			remove_element(sic)
		for orig in wordElemNorm.xpath(".//tei:choice//tei:orig", namespaces=nsmap):
			remove_element(orig)
		for am in wordElemNorm.xpath(".//tei:expan//tei:am", namespaces=nsmap):
			remove_element(am)
		for surplus in wordElemNorm.xpath(".//tei:surplus", namespaces=nsmap):
			remove_element(surplus)
		for g in wordElemNorm.xpath(".//tei:g", namespaces=nsmap):
			remove_element(g)
		
		# serialize the word elems to text
		wordElemText = etree.tostring(wordElem, encoding='utf8', method='xml').decode('utf-8').strip()
		wordElemText = wordElemText.replace('xmlns="http://www.tei-c.org/ns/1.0"', "")
		wordElemText = wordElemText.replace('xmlns:xi="http://www.w3.org/2001/XInclude"', "")

		#CR: handle extra whitespace where present
		wordElemText = re.sub(r'\s',' ',wordElemText)
		while re.search(r'  ',wordElemText):
			wordElemText = re.sub(r'  ',' ',wordElemText)

		# add version to unique/alphabetize on
		normalized = ''.join(wordElemNorm.itertext()).strip()

		#CR: changing to handle building wordlists per the current layout
		if wordElemText and len(wordElemText):
			inscrID, wordNum = wordElem.attrib[XML_NS + 'id'].split('-')
			inscrID = inscrID.strip()
			wordNum = wordNum.strip()
			lang = wordElem.attrib[XML_NS + 'lang']

			if wordElem.attrib[XML_NS + 'lang'] not in WORD_LISTS:
				WORD_LISTS[lang] = [["FileID","Word Num","Normalized","Language","w/n/naw","Element"]]	 
			WORD_LISTS[lang].append([inscrID, wordNum, normalized, lang, w_naw_num[wordElem.tag], wordElemText])

				

#Write word lists to CSV files
for lang in WORD_LISTS:

#write to file
	date = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M")
	with open(f'{strPathListOut}/{date}_wordlist-{lang.lower()}.csv', 'w') as csvfile:
		csvwriter = csv.writer(csvfile)
		for word_row in WORD_LISTS[lang]:
			csvwriter.writerow(word_row)

print("#" * 20)
print("#" * 20)
print("Total word count:")
print(WORD_COUNT)
print("Transformation errors:")
print(transformationErrors)
print("#" * 20)
