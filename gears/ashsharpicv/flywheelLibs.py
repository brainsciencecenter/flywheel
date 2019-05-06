#!/usr/bin/env python3

import sys
import re
import os
import flywheel
import json

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

