#!/usr/bin/env python3

import sys
import re
import os
import flywheel
import json
import argparse

from os.path import expanduser

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
        print("config file = ", config)
        if (config):
            ApiKey = config['inputs']['api-key']['key']
        else:
            raise SystemExit("No apikey file '%s', or config.json file '%s'. " % (ApiKeyFile, args.config_json))

    return(ApiKey)

if __name__ == '__main__':

    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('--config-json', type=str, default='/flywheel/v0/config.json', dest="config_json", help='Full path to the input config.json file.')
    ap.add_argument('--apikeyfile', type=str, default='~/.config/flywheel/api.key', dest="apikeyfile", help='Full path to the file containing the apikey.')
    ap.add_argument('--apikey', type=str, default=None, dest="apikey", help='apikey.')
    args = ap.parse_args()

    ApiKey = getApiKey(args)

    print(ApiKey)
