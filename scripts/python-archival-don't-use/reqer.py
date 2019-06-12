# this code is to request and get the api content
# by Yang Zhang, yangzhang@brown.edu

import requests
from bs4 import BeautifulSoup
import time
import random

API_TEI = 'https://api.zotero.org/groups/180188/items?tag={}&format=tei'
HEADERS = {'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
           'Connection': 'keep-alive',
           'Upgrade-Insecure-Requests': '1',
           'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36',
           }

import logging

def request_bytag(bibl_tag='IIP-521'):
  sleep_time = float(random.randint(100, 220) / 100)
  time.sleep(sleep_time)
  logging.debug('Sleep for {} seconds'.format(str(sleep_time)))
  try:
    bibl_tei = requests.get(API_TEI.format(bibl_tag), headers=HEADERS).content
  except Exception as e:
    logging.fatal('REQUESTING API FAILED')
  else:
    return BeautifulSoup(bibl_tei, 'xml')


def get_biblstruct(content):
  try:
    list_bibl = content.find('listBibl')
    biblstruct = list_bibl.find('biblStruct')
    if 'xml:id' in biblstruct.attrs:
      print('remove xml:id from biblStruct')
      del biblstruct['xml:id']
  except Exception as e:
    logging.fatal('FINDING biblSturct FAILED')
    return 'NoBiblStruct'
  else:
    return biblstruct


def get_biblstruct_bytag(bibl_tag='IIP-521'):
  return get_biblstruct(request_bytag(bibl_tag=bibl_tag))
