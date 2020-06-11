#!/usr/bin/python3
#Reaped Sessions

import csv
import flywheel
import fwgearutils
import sys
from pprint import pprint


import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-m', '--month', action='store', nargs=1, type=str, help='Month number, 1 = January, 12 = December')
parser.add_argument('-y', '--year', action='store', nargs=1, type=str, default=[2020], help='Year number')
parser.add_argument('out', type=argparse.FileType('w', encoding='UTF-8'))
args = parser.parse_args()

fw = fwgearutils.getFW(args)
project_data = []

for project in fw.get_all_projects(exhaustive=True):
    print('Counting project {}'.format(project.label), file=sys.stderr)
    reaper_count_hash = {}
    query = 'files.origin.type=device,parents.project={}'.format(project.id)
    for a in fw.acquisitions.find(query, exhaustive=True):
        reaper_count_hash[a.session] = 1
            
    query = 'parents.project={}'.format(project.id)
    sessions = fw.sessions.find(query, exhaustive=True, limit=10000)
    for session in sessions:
        project_data.append({
            'group_id': project.group,
            'project_label': project.label,
            'project_id': project.id,
            'reaped_session': session.id in reaper_count_hash.keys(),
            'session_created': session.created
        })

print('writing to session_counts.csv')
with open('session_counts.csv', 'w') as fp:
    writer = csv.DictWriter(fp, ['group_id', 'project_id', 'project_label', 'reaped_session', 'session_created','session_analyses'])
    writer.writeheader()
    for row in project_data:
        writer.writerow(row)
