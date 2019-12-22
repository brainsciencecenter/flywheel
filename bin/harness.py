#!/usr/bin/env python3

import fwgearutils
import json
import csv
import sys

with open(sys.argv[1], 'r') if len(sys.argv) > 1 else sys.stdin as csvfile:
    spamreader = csv.reader(csvfile, delimiter=' ')
    for row in spamreader:
        print('"%s"' % ('", "'.join(row)))    # read data using f

