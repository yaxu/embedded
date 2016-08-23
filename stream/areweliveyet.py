#!/usr/bin/python

import json
import urllib2

channel = "UC-id0vwQoAUYBNCm0nmaqQw"

f = open("/home/alex/Dropbox/keys/youtube.txt")
key = f.read()
f.close()
key = key.rstrip()


url = "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=%s&eventType=live&type=video&key=%s" % (channel, key)

response = urllib2.urlopen(url)
js = response.read()

h = json.loads(js)
live = False
if ("items" in h) && (len(h["items"]) >= 1):
    result = h["items"]["liveBroadCastContent"] == "live"
    if result:
      live = True

