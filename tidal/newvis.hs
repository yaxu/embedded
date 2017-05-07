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


totalWidth = 600 :: Double
ratio = 1/20

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
          C.scale x (y / (fromIntegral $ length levels))
          C.setOperator C.OperatorOver
          -- C.setSourceRGB 0 0 0
          -- C.rectangle 0 0 1 1
          --C.fill
          mapM_ (renderLevel (length levels)) $ enumerate levels
          C.restore

renderLevel total (n, level) = do C.save
                                  mapM_ drawEvent level
                                  C.restore
      where height = 1
            drawEvent (_, (s,e), c) = 
              do let (RGB r g b) = toSRGB c
                 C.setSourceRGBA 0.6 0.6 0.6 1
                 C.rectangle (x+lgap+w) (y+half -(lineH/2.0) - border) lineW lineH
                 C.fill
                 -- C.stroke
                 C.setSourceRGBA r g b 1
                 -- C.rectangle x y w h
                 C.arc x y (w/2) 0 (1 * pi)
                 C.fill
                 C.stroke
                   where x = (fromRational s)
                         y = (fromIntegral n) * height + border
                         w = (ratio) - (border * ratio * 2)
                         lineW = (fromRational (e-s)) - lgap - rgap - w
                         lineH = 0.03
                         lgap = 0.002
                         rgap = 0.01
                         border = 0.1
                         h = height - border*2
                         half = height / 2
                         quarter = height / 4
            vPDF = v C.withPDFSurface

vis name pat = do v (C.withSVGSurface) (name ++ ".svg") (totalWidth,((totalWidth * ratio)*(fromIntegral $ length levels))) levels
                  rawSystem "/home/alex/Dropbox/bin/fixsvg.pl" [name ++ ".svg"]
                  rawSystem "convert" [name ++ ".svg", name ++ ".pdf"]
                  return ()
                    where levels = arrangeEvents (arc pat (0,1))
