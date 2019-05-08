# -*- coding: utf-8 -*-
import subprocess
from tei2xml import *
import os
from os import listdir
from os.path import isfile, join
from pprint import pprint

def get_file_list():
  xmlfiles = [f for f in listdir(MYPATH) if isfile(join(MYPATH, f))]
  pprint('Number of files in this dir: {}'.format(str(len(xmlfiles))))
  pprint(xmlfiles)
  xmlfiles = [f for f in xmlfiles if f[-4:] == '.xml' and len(f) == len('abil0001.xml')]
  pprint('Number of XML qualified files in this dir: {}'.format(str(len(xmlfiles))))
  xmlfiles.sort()
  pprint(xmlfiles)
  return xmlfiles

MYPATH = 'epidoc-files/'
OUT_PATH_INTERMEDIATE = 'epidoc-files/outputAddPeriodo'
OUT_PATH = 'archival-files/{}'
SAXON_COMMAND = 'saxon -s:{} -xsl:make-archival.xsl -o:{}'

if __name__ == '__main__':
  xmlfiles = get_file_list()
  xmlfiles_a2f = xmlfiles[:xmlfiles.index('fakh0001.xml')]
  xmlfiles_f2z = xmlfiles[xmlfiles.index('fakh0001.xml'):]

  print(len(xmlfiles_a2f[:xmlfiles.index('erra0001.xml')]))
  xmlfiles_a2f_goon = xmlfiles_a2f[:]
  # print(xmlfiles_a2f_goon)
  xmlfiles_goon = xmlfiles_a2f + xmlfiles_f2z

  for filename in xmlfiles_goon:
    print('-'*20)
    print('Current processing:\t', filename)
    infilepath = os.path.join(ORIGINAL_XML_DIR, filename)
    outfilepath_intermediate = os.path.join(OUT_PATH_INTERMEDIATE, filename)
    saxon_command = SAXON_COMMAND.format(infilepath, outfilepath_intermediate)
    subprocess.call(saxon_command, shell=True)  
    infilepath = outfilepath_intermediate
    worker(infilepath, outfilepath=OUT_PATH.format(filename))
