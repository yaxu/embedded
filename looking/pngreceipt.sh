#!/bin/sh
echo Printing $1
convert $1 -resize 384 -depth 1 -define png:color-type=3 /tmp/printme.png
/usr/local/bin/png2escpos /tmp/printme.png | /usr/bin/lpr -Preceiptprinter -o raw

