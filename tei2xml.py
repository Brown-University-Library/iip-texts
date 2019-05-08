# this code is for put tei content into original XML,
# and output it to new XML file.
# by Yang Zhang, yangzhang@brown.edu

from bs4 import BeautifulSoup
import codecs
from reqer import *
from pprint import pprint

ORIGINAL_XML_DIR = 'epidoc-files/'

import logging

logging.basicConfig(
  level=logging.WARNING,
  format="%(asctime)s [%(threadName)-12.12s] [%(levelname)-5.5s]  %(message)s",

  handlers=[
    logging.FileHandler("{}.log".format('tei2xml')),
    # logging.StreamHandler()
  ])


def print_a_line():
  print('-*' * 20)


def get_original_name(filename):
  name = filename[filename.find(ORIGINAL_XML_DIR) + len(ORIGINAL_XML_DIR):]
  return name


def check_id(id1, id2):
  return id1 == id2


def remove_xml_from_id(id):
  return str(id).rstrip('.xml')


def worker(infilename=None, outfilepath='epidoc-files/outarchive/beth0061.xml'):
  origin_xml_filepath = 'epidoc-files/beth0061.xml' if infilename is None else infilename

  origin_xml_name = get_original_name(origin_xml_filepath)
  logging.debug('-*' * 10 + 'Current processing XML: {}'.format(origin_xml_name))
  fin = codecs.open(origin_xml_filepath, 'r+', 'utf-8')

  soup = BeautifulSoup(fin, 'xml')
  list_bibl = soup.find('div', type='bibliography').find('listBibl')
  fin.close()

  logging.debug("Current processing:\n\n{}\n\n".format(str(list_bibl)))

  bibl_in_list = [one for one in list_bibl.find_all('bibl')]
  bibl_tags_wixml = [one.find('ptr').get('target') for one in bibl_in_list]  # bibl tags with 'xml'
  bibl_tags_woxml = [remove_xml_from_id(one) for one in bibl_tags_wixml]  # bibl tags without 'xml'

  bibl_cited_range = [one.find('biblScope') for one in bibl_in_list]
  for one in bibl_cited_range:
    one.name = 'citedRange'  # change from "biblScope" to "citedRange"

  bibl_struct_list_new = []
  for i, id in enumerate(bibl_tags_woxml):
    bibl_struct = get_biblstruct_bytag(id)
    new_tag_citedrange = bibl_cited_range[i]

    if bibl_struct != 'NoBiblStruct':
      bibl_struct.append(new_tag_citedrange)
      bibl_struct_list_new.append(bibl_struct)
    else:
      logging.error('[FAILURE]{} got a NULL Bibl Struct, id:\t{}'.format(origin_xml_name, id))
      bibl_struct_list_new.append('NoBiblStruct')

  # remove the original bibl, which has no detail info
  id_original = []
  for one in list_bibl.find_all('bibl'):
    id_original.append(
      remove_xml_from_id(one.find('ptr').get('target'))
    )
    one.decompose()
  list_bibl.string = ''

  for i, biblstruct in enumerate(bibl_struct_list_new):
    try:
      id_origin = id_original[i]
      id_current = biblstruct.find('idno')

      if id_current is not None and id_current != -1:  # sometimes id_current is lost, just forget it and never mind, we will not check it
        id_current = id_current.text
      else:
        id_current = id_origin

    except Exception as e:
      logging.error(str(e))
      logging.error('[FAILURE] Error while extracting id')
    if check_id(id_origin, id_current):
      if biblstruct != 'NoBiblStruct':
        list_bibl.append(biblstruct)
      else:
        logging.error('[FAILURE]{} got a NULL Bibl Struct, id:\t{}'.format(origin_xml_name, id_origin))
    else:
      logging.error('[FAILURE]Error while checking id:\t', id_current)
      # raise Exception

  with open(outfilepath, "wb") as file:
    file.write(str(soup).encode('utf-8'))


if __name__ == '__main__':
  worker()
