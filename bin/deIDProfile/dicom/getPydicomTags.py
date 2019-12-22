#!/usr/bin/python3

# Gets a list of tags from the pyDicom dictionary

import csv
import pydicom

from pydicom.datadict import DicomDictionary

keyList = list(DicomDictionary.keys())

keyList.sort()

tagsAndKeywords = len(keyList) * [None]

for i in range(len(keyList)):
  hexKey = '%08X' % keyList[i]
  tag = '(' + hexKey[0:4] + ',' + hexKey[4:] + ')'
  tagsAndKeywords[i] = [tag, DicomDictionary[keyList[i]][4]]

# Add header
tagsAndKeywords.insert(0, ['Tag','Keyword'])

with open('pydicomTags.csv', 'w') as csvFile:
  writer = csv.writer(csvFile)
  writer.writerows(tagsAndKeywords)

csvFile.close()
