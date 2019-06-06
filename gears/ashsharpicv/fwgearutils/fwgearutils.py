#!/usr/bin/env python3

import sys
import re
import os
import flywheel
import json
import datetime
import pytz

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
    ApiKeyFile = '~/.config/flywheel/api.key'
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

def sloppyCopy(d):
    '''
    serializes a object, ignoring all the stuff it cant easily serialize, but will give you something
    '''
    
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
                    nd[k] = sloppyCopy(d[k])

            # print("sloppyCopy: d is sorta dict", nd.copy(), file=sys.stderr)
            return(nd.copy())

       if (type(d) is list):
            nd = []
            for i in d:
                nd.append(sloppyCopy(i))

            # print("sloppyCopy: d is list", nd.copy(), file=sys.stderr)
            return(nd.copy())
       if (type(d) is datetime.datetime):
          timezone = pytz.timezone("America/New_York")
          d_localtz = d.astimezone(pytz.timezone("America/New_York"))
          return(d_localtz.strftime("%Y%m%d %X"))

        # print("sloppyCopy: d is type ", type(d), file=sys.stderr)
 

