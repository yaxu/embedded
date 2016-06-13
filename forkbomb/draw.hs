
import Graphics.Rendering.Cairo
import Canvas
  
main = canvas draw 600 600

draw w g t =
  do color white
     rectangle 0 0 w g
     fill
     color black
     rectangle 0 0 10 10
     fill
