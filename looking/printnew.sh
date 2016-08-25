#!/bin/bash

cd /home/pi/embedded
git pull
cd /home/pi/bin
find /home/pi/embedded/print/*png -newer .timestamp -exec ./pngreceipt.sh {} \;
touch .timestamp
