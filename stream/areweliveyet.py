#!/usr/bin/python

import json
import urllib2
import sys
import re

def is_live():
  #url = "http://slab.org:9090/stat.xsl"
  #response = urllib2.urlopen(url)
  #x = response.read()
  x= "blabber"
  f = open("livestate.txt", "w")
  if "<name>yaxu</name>" in x and "<video>" in x:
      f.write("live\n")
      result = True
  else:
      f.write("offline\n")
      result = False
  f.close()
  return(result)

def was_live():
    f = open("livestate.txt")
    value = f.read() 
    f.close()
    value = value.rstrip()
    if value == "live":
        return(True)
    else:
        return(False)

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
        # It probably is live, just youtube api is slow to update
        return("Live stream")

def live_mode():
    pass

def archive_mode():
    pass

def write_srt():


livestate = was_live()

if is_live():
    title = get_info()
    print(title)
    if livestate == False:
        live_mode()
    write_srt(title)
else:
    print "Not live."
    if livestate = True:
        archive_mode()
