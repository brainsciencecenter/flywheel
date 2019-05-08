#!/usr/bin/env python3

import sys
import re
import os
import flywheel
import json

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
   
   if (type(d) is dict):
      for k in d.keys():
         rd[encode(k)] = encodeKeys(d[k])
   else:
      rd = d

   return(rd)

def decodeKeys(d):
   rd = {}
   
   if (type(d) is dict):
      for k in d.keys():
         rd[decode(k)] = decodeKeys(d[k])
   else:
      rd = d

   return(rd)

# command line arg for the api key itself
# command line arg for the api key file
# default file for api key file
# command line for the config json
# default file for config file
# give up


def getConfigJson(args):
   if os.path.isfile(args.config_json):
       with open(args.config_json, 'r') as jsonfile:
           config = json.load(jsonfile)
   else:
       config = None

   return(config)

def getApiKey(args):
    ApiKey = None
    ApiKeyFile = expanduser(args.apikeyfile)

    if (args.apikey):
        ApiKey = args.apikey
    elif (os.path.isfile(ApiKeyFile)):
        with open(ApiKeyFile) as x: ApiKey = x.read().rstrip()
    else:
        config = getConfigJson(args)
        if (config):
            ApiKey = config['inputs']['api-key']['key']
        else:
            raise SystemExit("No apikey file '%s', or config.json file '%s'. " % (ApiKeyFile, args.config_json))

    return(ApiKey)


