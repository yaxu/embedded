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
example = hcat
  [eff, eff # scale 2, eff # scaleX 2, eff # scaleY 2, eff # rotateBy (1/12)]

main = mainWith example
