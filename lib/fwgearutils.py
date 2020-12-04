#!/usr/bin/env python3

import sys
import re
import os
import flywheel
import json
import datetime
import pytz
import globre

from os.path import expanduser

def encode(s):
   r = re.sub('\_','_dash_',s)
   r = re.sub('\.','_dot_',r)
   return(r)

def decode(s):
   r = re.sub('_dash_','_',s)
   r = re.sub('_dot_','.',r)
   return(r)

def encodeKeys(d):
   rd = {}
   
   try:
      for k in d.keys():
         rd[encode(k)] = encodeKeys(d[k])
   except (AttributeError,KeyError):
      rd = d

   return(rd)

def decodeKeys(d):
   rd = {}
   
   try:
      for k in d.keys():
         rd[decode(k)] = decodeKeys(d[k])
   except (AttributeError,KeyError):
      rd = d

   return(rd)

# command line arg for the api key itself
# command line arg for the api key file
# default file for api key file
# command line for the config json
# default file for config file
# give up


def getConfigJson(config_json):
   if os.path.isfile(config_json):
       with open(config_json, 'r') as jsonfile:
           config = json.load(jsonfile)
   else:
       config = None

   return(config)

def getApiKey(args):
    ApiKey = None
    ApiKeyFile = expanduser('~/.config/flywheel/api.key')
    ConfigJson = '/flywheel/v0/config.json'

    if (hasattr(args,'apikeyfile') and args.apikeyfile):
       ApiKeyFile = expanduser(args.apikeyfile)
       
    if (hasattr(args,'apikey') and args.apikey):
        ApiKey = args.apikey
    elif (os.path.isfile(ApiKeyFile)):
        with open(ApiKeyFile) as x: ApiKey = x.read().rstrip()
    else:
       if (hasattr(args,'config_json') and args.config_json):
          ConfigJson = args.config_json

       if (os.path.isfile(ConfigJson)):
          config = getConfigJson(ConfigJson)
          if (config):
             ApiKey = config['inputs']['api-key']['key']
          else:
             raise SystemExit("No apikey file '%s', or config.json file '%s'. " % (ApiKeyFile, args.config_json))

    return(ApiKey)

def getFW(args, Root=False):
   
    try:
        fw = flywheel.Client()
        return(fw)
    except (OSError, Exception, flywheel.rest.ApiException) as e:
        try:
           ApiKey = getApiKey(args)

           fw = flywheel.Client(ApiKey)
           return(fw)
        
        except (OSError, Exception, flywheel.rest.ApiException) as e2:
           print("e2",e2, file=sys.stderr)
           print("e",e, file=sys.stderr)
           sys.exit(1)

def fwGlobPath(fw,Path):
    Groups = []
    Projects = []
    Subjects = []
    Sesions = []

    Segments = Path.split('/')
    Containers = {}

    if (len(Segments) >= 0):
        Groups = [ Group for Group in fw.groups() if (globre.match(Segments[0], Group.id)) ]
        for Group in Groups:
            Containers[Group.id] = Group

    CurrentPath = []
    if (len(Segments) > 1):
        Projects = {}
        for GroupPath, Group in Containers.items():
            for Project in Group.projects():
                if (globre.match(Segments[1], Project.label)):
                    Projects['/'.join([GroupPath, Project.label])] = Project

        Containers = Projects

    if (len(Segments) > 2):
        Subjects = {}
        for ProjectPath, Project in Containers.items():
            for Subject in Project.subjects():
                if (globre.match(Segments[2], Subject.label)):
                    Subjects[ '/'.join([ProjectPath, Subject.label])] = Subject

        Containers = Subjects

    if (len(Segments) > 3):
        Sessions = {}
        for SubjectPath, Subject in Containers.items():
            for Session in Subject.sessions():
                if (globre.match(Segments[3], Session.label)):
                    Sessions[ '/'.join([SubjectPath, Session.label])] = Session

        Containers = Sessions

    if (len(Segments) > 4):
        Acquisitions = {}
        for SessionPath, Session in Containers.items():
            for Acquisition in Session.acquisitions():
                if (globre.match(Segments[3], Session.label)):
                    Acquisitions[ '/'.join([SessionPath, Acquisition.label])] = Acquisition

        Containers = Acquisitions

    return(Containers)

def sloppyCopy(d, recurse=True, UTC=True):
    '''
    serializes a object, ignoring all the stuff it cant easily serialize, but will give you something
    '''

    from tzlocal import get_localzone

    # print("sloppyCopy: ", d, file=sys.stderr)
    try:
        json.dumps(d)
        #print("sloppyCopy d is serializable", file=sys.stderr)
        return(d)

    except (TypeError, OverflowError) as e:
       if (hasattr(d,'keys')):
            nd = {}
            for k in d.keys():
                try:
                    json.dumps(d[k])
                    nd[k] = d[k]
                except (TypeError, OverflowError) as e2:
                   #print("Object '%s' key '%s' not json serialable" % (type(d[k]),k), file=sys.stderr)
                   if (recurse): 
                      nd[k] = sloppyCopy(d[k], UTC=UTC)

            # print("sloppyCopy: d is sorta dict", nd.copy(), file=sys.stderr)
            return(nd)

       if (type(d) is list):
            nd = []
            for i in d:
               if (recurse):
                  nd.append(sloppyCopy(i, UTC=UTC))

            # print("sloppyCopy: d is list", nd.copy(), file=sys.stderr)
            return(nd)

       if (type(d) is datetime.datetime):
          #d.datetime.datetime is supposed to be in UTC 
          if (UTC):
             return(d.strftime("%Y-%m-%dT%H:%M:%S%z"))
          else:
             return(d.astimezone(get_localzone()).strftime("%Y-%m-%dT%H:%M:%S%z"))




def recurse(fw, r, GetAcquisitions=False, CmdName="", Debug=False, Get=False, UTC=True, Verbose=False, ZipInfo=False ):

    if (Get):
        try:
           if (type(r) == flywheel.models.job_list_entry.JobListEntry):
              r = r.reload()
           else:
              r = fw.get(r._id)
        except (flywheel.rest.ApiException) as e:
           print("%s : Exception : %s" % (CmdName, e), file=sys.stderr)
           print("%s : r is type : %s" % (CmdName, type(r)), file=sys.stderr)
           True

    if (Debug):
        print(type(r), file=sys.stderr)

    Output = sloppyCopy(r, UTC=UTC)

    if (type(r) == flywheel.models.resolver_group_node.ResolverGroupNode):
        if (Verbose):
            print("%s : r == Group %s" % (CmdName,r._id), file=sys.stderr)

        Projects = []
        for p in r.projects():
            if (Verbose):
                print("%s : %s/%s" % (CmdName, r._id, p.label), file=sys.stderr)

            Project = recurse(fw, p, GetAcquisitions=GetAcquisitions, CmdName=CmdName, Debug=Debug, Get=Get, UTC=UTC, Verbose=Verbose, ZipInfo=ZipInfo)
            Projects.append(sloppyCopy(Project, UTC=UTC))

        Output['projects'] = Projects
                
    if (  type(r) == flywheel.models.job_list_entry.JobListEntry
       or type(r) == flywheel.models.job.Job ):
       Output['detail'] = sloppyCopy(fw.get_job_detail(r.id), UTC=UTC)
       try:
          profile = sloppyCopy(r['profile'], UTC=UTC)
          Output['profile'] = profile
       except (AttributeError, TypeError) as e:
          if (Debug):
             print("No profile for {}".format(r.id), file=sys.stderr)

    if (   type(r) == flywheel.models.project.Project 
        or type(r) == flywheel.models.resolver_project_node.ResolverProjectNode 
        or type(r) == flywheel.models.container_project_output.ContainerProjectOutput):
        if (Verbose):
            print("%s : r == project" % (CmdName), file=sys.stderr)

        Subjects = []
        for s in r.subjects():
            if (Verbose):
                print("%s : %s/%s" % (CmdName, r.label, s.label), file=sys.stderr)

            Subject = recurse(fw, s, GetAcquisitions=GetAcquisitions, CmdName=CmdName, Debug=Debug, Get=Get, UTC=UTC, Verbose=Verbose, ZipInfo=ZipInfo)
            Subjects.append(sloppyCopy(Subject, UTC=UTC))
        Output['subjects'] = Subjects
        
    elif (   type(r) == flywheel.models.subject.Subject 
          or type(r) == flywheel.models.resolver_subject_node.ResolverSubjectNode 
          or type(r) == flywheel.models.container_subject_output.ContainerSubjectOutput):
        if (Debug):
            print("r == subject", file=sys.stderr)

        Sessions = []
        for s in fw.get_subject_sessions(r._id):
            if (Verbose):
                print("%s : %s/%s" % (CmdName, r.label, s.label), file=sys.stderr)
            Session = recurse(fw, s, GetAcquisitions=GetAcquisitions, CmdName=CmdName, Debug=Debug, Get=Get, UTC=UTC, Verbose=Verbose, ZipInfo=ZipInfo)
            Sessions.append(sloppyCopy(Session, UTC=UTC))
        Output['sessions'] = Sessions

    elif (   type(r) == flywheel.models.session.Session 
          or type(r) == flywheel.models.resolver_session_node.ResolverSessionNode 
          or type(r) == flywheel.models.container_session_output.ContainerSessionOutput):
        if (Verbose):
            print("%s : r == session(%s)" % (CmdName, r.label), file=sys.stderr)

        if (r.analyses):
            Analyses = []
            for a in r.analyses:
                Analysis = sloppyCopy(a, UTC=UTC)
                Analyses.append(Analysis)
            Output['analyses'] = Analyses

        Acquisitions = []

        if (Debug):
            print("%s : Starting acquisitions = '%s'" % (CmdName,GetAcquisitions), file=sys.stderr)
            
        if (GetAcquisitions):
            if (Debug):
                print("%s : Looking for acquisitions = '%s'" % (CmdName,GetAcquisitions), file=sys.stderr)
            
            for a in r.acquisitions():
                Acquisition = recurse(fw, a, GetAcquisitions=GetAcquisitions, CmdName=CmdName, Debug=Debug, Get=Get, UTC=UTC, Verbose=Verbose, ZipInfo=ZipInfo)
                Acquisitions.append(sloppyCopy(Acquisition, UTC=UTC))

        Output['acquisitions'] = Acquisitions

    elif (   type(r) == flywheel.models.acquisition.Acquisition 
          or type(r) == flywheel.models.resolver_acquisition_node.ResolverAcquisitionNode 
          or type(r) == flywheel.models.container_acquisition_output.ContainerAcquisitionOutput):
        if (Verbose):
            print("%s : r == acquisition : %s" % (CmdName, r.label), file=sys.stderr)

    if (ZipInfo):
        Files = []

        try:
            for f in r.files:
                File = sloppyCopy(f, UTC=UTC)
                if (re.search('\.zip$', f.name)):
                    if (f.size > 0):
                        try:
                            File['zip_info'] = sloppyCopy(r.get_file_zip_info(f.name), UTC=UTC)
                            File['zip_member_count'] = len(File['zip_info']['members'])

                            if (Verbose):
                                print("%s : '%s/files/%s' %d" % (CmdName, r.label, f.name, File['zip_member_count']), file=sys.stderr)

                        except (flywheel.rest.ApiException) as e:
                            print("%s : %s(%s).get_file_zip_info failed on '%s' : %s - %s\n" % (CmdName, r.label, r.id, f.name, e.status, e.reason), file=sys.stderr)
                            continue
                    else:
                        print("%s : Size of '%s(%s)/%s' is 0 : Skipping\n" % (CmdName, r.label, r.id, f.name), file=sys.stderr)
                        continue
                else:
                    if (Verbose):
                        print("%s : '%s/files/%s'" % (CmdName, r.label, f.name), file=sys.stderr)

                Files.append(File)

        except (AttributeError) as e:
            # no files attribute
            True

        if (len(Files) > 0):
            Output['files'] = Files

    return(Output)

