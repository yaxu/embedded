#!/usr/bin/python

# hacky script to show a stream on a raspberry pi while its live, and
# an archive video at other times

import json
import urllib2
import sys
import re
import time
import os

def is_live():
  url = "http://slab.org:9090/stat.xsl"
  response = urllib2.urlopen(url)
  x = response.read()
  s = "<name>yaxu</name>"
  f = open("livestate.txt", "w")
  # hack - todo parse properly
  if s in x and "<video>" in x:
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
    print "live mode"
    os.system("cp video-live.sh video.sh")
    os.system("killall omxplayer.bin")

def archive_mode():
    print "archive mode"
    os.system("cp video-archive.sh video.sh")
    os.system("killall omxplayer.bin")

def write_live_srt(title):
    f = open("../video/live.srt", "w")
    f.write("1\n00:00:00,000 --> 01:00:00,000\nLooking screen\n%s\n\n" % (title,))
    f.close()

first = True

while True:
  livestate = was_live()
  if is_live():
    title = get_info()
    print(title)
    if livestate == False or first:
      live_mode()
      first = False
    write_live_srt(title)
  else:
    print "Not live."
    if livestate == True or first:
      first = False
      archive_mode()
  time.sleep(5)
