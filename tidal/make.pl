#!/usr/bin/perl -w

use strict;

undef $/;
my ($code) = <>;

open($fh, ">Code.hs");

my $escaped = quotemeta($code);

print $fh qq!
wrap :: String -> [String]
wrap [] = []
wrap s = ((take 200 s) : (wrap (drop 200 s)))

drawText description pat =
  do let w = 136
         h = 566
     withSVGSurface ("text.svg") w h \$ \surf -> do
        renderWith surf \$ do
          C.save 
          C.scale (w-20) (h)
          C.setOperator C.OperatorOver
          C.setSourceRGB 0 0 0 
          C.rectangle 0 0 1 1
          C.fill
          mapM_ renderEvent (events pat)
          C.restore 
          return ()
          save
          setSourceRGB 0 0 0
          selectFontFace "Terminal Dosis" FontSlantNormal FontWeightNormal
          setFontSize 12
          rotate (pi/ 2)
          moveTo 5 (negate (w-15))
          textPath description
          fill
          restore
     rawSystem "inkscape" ["--without-gui", "--export-pdf=text.pdf", "text.svg"]


main = drawText "$escaped" ("black white")
!;
close $fh;
