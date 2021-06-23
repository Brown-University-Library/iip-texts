#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Parse command line input for list of filenames.

Created on Wed Jun 12 14:21:02 2019

@author: christiancasey
"""


import argparse

def ParseArguments():
	parser = argparse.ArgumentParser(description="""
		Add filenames of texts as command line arguments in order to process a subset of all texts.
		The list of texts should be in the form: "file1, file2, file3, etc".
		""")
	
	parser.add_argument('--texts', '-t', type=str, default='', help='The list of texts to process')
	
	args = parser.parse_args()
	if len(args.texts) > 0:
		vFilenames = args.texts.split(', ')
	else:
		vFilenames = None
	
	return vFilenames