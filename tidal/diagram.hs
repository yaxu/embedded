{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE FlexibleContexts          #-}
{-# LANGUAGE TypeFamilies              #-}

import qualified Diagrams.Prelude as D
import Diagrams.Backend.SVG.CmdLine
import Sound.Tidal.Context
-- or:
-- import Diagrams.Backend.xxx.CmdLine
-- where xxx is the backend you would like to use.

myCircle :: Diagram B
myCircle = circle 1

eff = (text "F" <> square 1) # fontSize (local 1)

example :: Diagram B
example = D.hcat
  [eff, eff # D.scale 2, eff # D.scaleX 2, eff # D.scaleY 2, eff # D.rotateBy (1/12)]

main = mainWith example
