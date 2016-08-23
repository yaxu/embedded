#!/usr/bin/python

import json


f = open("/home/alex/Dropbox/keys/youtube.txt")
key = f.read()
f.close()
key.rstrip()
print key
