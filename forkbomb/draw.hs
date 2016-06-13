
import Graphics.Rendering.Cairo

w = 300
h = 300

main = withImageSurface FormatARGB32 w h $ \surf ->
  do renderWith surf $
       do setOperator OperatorOver
          setSourceRGB 0 0 0
          rectangle 0 0 (floor w) (floor h)
          fill
          setSourceRGB 1 1 1
          rectangle 0 0 100 100
          fill
     surfaceWriteToPNG surf "test.png"
     
       
  
