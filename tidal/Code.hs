
module Code where

import Sound.Tidal.Vis
import qualified Graphics.Rendering.Cairo as C 
import Graphics.Rendering.Cairo
import Data.Colour
import Data.Colour.Names
import Data.Colour.SRGB
import System.Process
import Sound.Tidal.Context

wrap :: String -> [String]
wrap [] = []
wrap s = ((take 200 s) : (wrap (drop 200 s)))

drawLines pat cyclesPerLine nLines =
  do C.save 
     C.scale 1 (1 / (fromIntegral nLines))
     C.setOperator C.OperatorOver
     C.setSourceRGB 0 0 0 
     C.rectangle 0 0 1 1
     C.fill
     mapM_ (\x -> do C.save
                     C.translate 0 (fromIntegral x)
                     drawLine ((cyclesPerLine * (fromIntegral x)) ~> pat)
                     C.restore
           ) [0 .. (nLines - 1)]
     C.restore
  where drawLine p = mapM_ renderEvent (events (density cyclesPerLine p))

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
          drawLines pat 1 70
          -- mapM_ renderEvent (events pat)
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

main = drawText "palindrome $ slowspread (density) [3,1.5] $ every 3 (rev) $ p \"{grey lightgrey darkgrey black lightgrey, grey black}\"" (palindrome $ slowspread (density) [3,1.5] $ every 3 (rev) $ p "{grey lightgrey darkgrey black lightgrey, grey black}")
