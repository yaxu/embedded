#!/usr/bin/perl -w

use strict;

undef $/;
my ($code) = <>;

my $fn = open("Code.hs", "w");

my $escaped = quotemeta($code);

print $fn qq!
wrap :: String -> [String]
wrap [] = []
wrap s = ((take 200 s) : (wrap (drop 200 s)))

drawText description pat =
  do let w = 136
         h = 566
     withSVGSurface ("text.svg") w h $ \surf -> do
        renderWith surf $ do
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
          textPath "foldEvery [3,5] (slow 2) $ density 16 $ \"grey black\""
          fill
          {-
          let ls = zip (wrap "foldEvery [3,5] (slow 2) $ density 16 $ \"grey black\"")
                       [0, 10 ..]
          mapM (\(s,n) -> do {moveTo 10 (n-(w-20)); textPath s; fill}) ls
          -}
          restore
     rawSystem "inkscape" ["--without-gui", "--export-pdf=text.pdf", "text.svg"]


main = drawText "$escaped"
!;
close $fn;
