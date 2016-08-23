#!/usr/bin/python

import json

channel = "UC-id0vwQoAUYBNCm0nmaqQw"

f = open("/home/alex/Dropbox/keys/youtube.txt")
key = f.read()
f.close()
key = key.rstrip()
print key

"https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=%s&eventType=live&type=video&%s"
