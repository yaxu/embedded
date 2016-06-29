
module Code where

import Sound.Tidal.Vis
import qualified Graphics.Rendering.Cairo as C 
import Data.Colour
import Data.Colour.Names
import Data.Colour.SRGB
import System.Process
import Sound.Tidal.Context

wrap :: String -> [String]
wrap [] = []
wrap s = ((take 200 s) : (wrap (drop 200 s)))

drawText
  :: C.CairoString string =>
     string
     -> Sound.Tidal.Context.Pattern (Colour Double)
     -> IO ()
drawText description pat =
  do let w = 136
         h = 566
     C.withSVGSurface ("text.svg") w h $ \surf -> do
        C.renderWith surf $ do
          C.save 
          C.scale (w-20) (h)
          C.setOperator C.OperatorOver
          C.setSourceRGB 0 0 0 
          C.rectangle 0 0 1 1
          C.fill
          mapM_ renderEvent (events pat)
          C.restore 
          C.save
          C.setSourceRGB 0 0 0
          C.selectFontFace "Terminal Dosis" C.FontSlantNormal C.FontWeightNormal
          C.setFontSize 12
          C.rotate (pi/ 2)
          C.moveTo 5 (negate (w-15))
          C.textPath description
          C.fill
          C.restore
     rawSystem "inkscape" ["--without-gui", "--export-pdf=text.pdf", "text.svg"]
     return ()


main = drawText ("red blue" :: String) ("black white" :: Sound.Tidal.Context.Pattern (Colour Double))
