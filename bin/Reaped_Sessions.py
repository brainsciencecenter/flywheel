#!/usr/bin/python3
#Reaped Sessions

import csv
import flywheel
import fwgearutils
import json
import os
import sys
from pprint import pprint


import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-m', '--month', action='store', nargs=1, type=str, help='Month number, 1 = January, 12 = December')
parser.add_argument('-y', '--year', action='store', nargs=1, type=str, default=[2020], help='Year number')
parser.add_argument('out', nargs="*", help='output file or stdout by default')
args = parser.parse_args()

fw = fwgearutils.getFW(args)
project_data = []

acquisitions = []

for project in fw.get_all_projects(exhaustive=True):

    reaper_count_hash = {}
    query = 'files.origin.type=device,parents.project={}'.format(project.id)
    query = 'parents.project={}'.format(project.id)
    '''
    for a in 
        reaper_count_hash[a.session] = 1
        acquisitions.append(a)
    '''

    origin = {'id': None, 'type': None}
    a = fw.acquisitions.find(query, exhaustive=True)
    if (len(a)):
        try:
            origin = { 'id': a[0].files[0].origin.id, 'type': a[0].files[0].origin.type }
            print("{} from {}".format(a[0].label,origin), file=sys.stderr)
        except (IndexError) as e:
            print("{} has no files".format(a[0].label),  file=sys.stderr)

    query = 'parents.project={}'.format(project.id)
    sessions = fw.sessions.find(query, exhaustive=True, limit=10000)
    for session in sessions:
        project_data.append({
            'session_created': session.created,
            'group_id': project.group,
            'project_label': project.label,
            'project_id': project.id,
            'session_id': session.id,
            'origin_id': origin['id'],
            'origin_type': origin['type'],
        })

with (os.fdopen(os.dup(sys.stdout.fileno()), 'w')
      if (len(args.out) == 0)
      else open(args.out[0], 'w')) as fp:
    writer = csv.DictWriter(fp, ['session_created', 'group_id', 'project_label', 'project_id', 'session_id', 'origin_id', 'origin_type' ])
    writer.writeheader()
    for row in project_data:
        writer.writerow(row)
