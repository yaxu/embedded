{-# LANGUAGE NoMonomorphismRestriction #-}
{-# LANGUAGE FlexibleContexts          #-}
{-# LANGUAGE TypeFamilies              #-}

import qualified Diagrams.Prelude as D
import Diagrams.Backend.SVG.CmdLine
import Sound.Tidal.Context
-- or:
-- import Diagrams.Backend.xxx.CmdLine
-- where xxx is the backend you would like to use.

myCircle :: D.Diagram B
myCircle = D.circle 1

eff = (D.text "F" <> D.square 1) # D.fontSize (D.local 1)

let (##) = D.#

example :: D.Diagram B
example = D.hcat
  [eff, eff # D.scale 2, eff # D.scaleX 2, eff # D.scaleY 2, eff # D.rotateBy (1/12)]

main = mainWith example
