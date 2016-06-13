
import Graphics.Rendering.Cairo

w :: Int
w = 800

h :: Int
h = 800

cellw = 4
cellh = 4
cols = w `div` 4

main = do h <- openFile "10.txt" ReadMode
          contents <- hGetContents h
          hClose h
          withImageSurface FormatARGB32 (floor w) (floor h) $ \surf ->
  do renderWith surf $
       do setOperator OperatorOver
          setSourceRGB 1 1 1
          rectangle 0 0 (fromIntegral w) (fromIntegral h)
          fill
          setSourceRGB 0 0 0
          rectangle 0 0 100 100
          fill
     surfaceWriteToPNG surf "test.png"
     

rle :: Eq a => [a] -> [(Int, a)]
rle = map (\x -> (length x, head x)) . group
