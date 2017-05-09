import qualified Graphics.Rendering.Cairo as C 
import Data.Colour
import Data.Colour.Names
import Data.Colour.SRGB
import Control.Applicative
import Sound.Tidal.Parse
import Sound.Tidal.Pattern
import Sound.Tidal.Time
import Sound.Tidal.Utils
import Data.Ratio
import Data.Maybe
import System.Cmd
import Data.List

totalWidth = 600 :: Double
ratio = 1/40
levelHeight = totalWidth * ratio

arrangeEvents [] = []
arrangeEvents (e:es) = addEvent e (arrangeEvents es)
fits e es = null $ filter (id) $ map (\e' -> isJust $ subArc (snd' e) (snd' e')) es
addEvent e [] = [[e]]
addEvent e (level:levels) | fits e level = (e:level):levels
                          | otherwise = level:(addEvent e levels)

v sf fn (x,y) levels =
      sf fn x y $ \surf -> do
        C.renderWith surf $ do
          C.save
          -- C.scale x (y / (fromIntegral $ length levels))
          C.setOperator C.OperatorOver
          -- C.setSourceRGB 0 0 0
          -- C.rectangle 0 0 1 1
          --C.fill
          mapM_ (renderLevel (length levels)) $ enumerate levels
          C.restore

renderLevel total (n, level) = do C.save
                                  mapM_ drawEvent $ sortOn (fst . snd') $ level
                                  C.restore
      where drawEvent (_, (s,e), c) = 
              do let (RGB r g b) = toSRGB c
                 C.setSourceRGBA 0.6 0.6 0.6 1
                 C.rectangle (x + half) y lineW levelHeight
                 let pat = C.patternCreateLinear r g b 256.0
                 C.addColorStopRGBA pat 0 r g b 1
                 C.addColorStopRGBA pat 1 r g b 1
                 C.setSource pat
                 -- C.setSourceRGBA r g b 1
                 C.fill
                 C.arc (x+half) (y+half) (w/2) 0 (2 * pi)
                 --C.rectangle x y w w
                 -- C.stroke
                 C.fill
                 -- C.stroke
                   where x = (fromRational s) * totalWidth
                         y = (fromIntegral n) * levelHeight
                         w = levelHeight
                         lineW = ((fromRational $ e-s) * totalWidth)
                         lineH = 2
                         lgap = 3
                         rgap = 3
                         border = 3
                         half = levelHeight / 2
                         quarter = levelHeight / 4
            vPDF = v C.withPDFSurface

vis name pat = do v (C.withSVGSurface) (name ++ ".svg") (totalWidth, levelHeight*(fromIntegral $ length levels)) levels
                  rawSystem "/home/alex/Dropbox/bin/fixsvg.pl" [name ++ ".svg"]
                  rawSystem "convert" [name ++ ".svg", name ++ ".pdf"]
                  return ()
                    where levels = arrangeEvents (arc pat (0,1))
