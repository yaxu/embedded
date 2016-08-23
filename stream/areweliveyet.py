#!/usr/bin/python

import json
import urllib2
import sys
import re

def is_live():
  url = "http://slab.org:9090/stat.xsl"
  response = urllib2.urlopen(url)
  x = response.read()
  s = "<name>yaxu</name>"
  if s in x:
      return(1)
  else:
      return(0)

def get_info():
    channel = "UC-id0vwQoAUYBNCm0nmaqQw"
    f = open("youtube.txt")
    key = f.read()
    f.close()
    key = key.rstrip()

    url = "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=%s&eventType=live&type=video&key=%s" % (channel, key)

    response = urllib2.urlopen(url)
    js = response.read()

    h = json.loads(js)
    live = False
    if (("items" in h)):
        for item in h["items"]:
            result = item["snippet"]["liveBroadcastContent"] == "live"
            if result:
                live = True
                title = item["snippet"]["title"]
                description = item["snippet"]["description"]

    if live:
        return("Live stream: " + title)
    else:
        return("Live stream")
        
if is_live():
    title = get_info()
    print(title)
else:
    print "Not live."
