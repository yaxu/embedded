import System.IO
import Data.List
import Graphics.Rendering.Cairo

w :: Int
w = 800

h :: Int
h = 800

cellw = 4
cellh = 4
cols = w `div` 4

main = do handle <- openFile "10.txt" ReadMode
          contents <- hGetContents handle
          hClose handle
          withImageSurface FormatARGB32 w h $ \surf -> do
            renderWith surf $ do
              setOperator OperatorOver
              setSourceRGB 1 1 1
              rectangle 0 0 (fromIntegral w) (fromIntegral h)
              fill
              setSourceRGB 0 0 0
              -- drawCells 0 0 (rle contents)
            surfaceWriteToPNG surf "test.png"


-- drawCells :: Int -> Int -> [(Int, Int)] -> IO ()
--           rectangle 0 0 100 100
--          fill

-- rleXY :: [(Int, a)] -> [(Int, Int), (Int, a)]
rleXY [] = []
rleXY xs = map toxy $ rlepos 0 xs
  where rlepos pos ((count, v):xs) = ((pos, count, v):(rlepos (pos+count) xs))
        toxy (pos, count, v) = (pos `div` cols, pos `mod` cols, count, v)

splitRLE _ _  [] = []
splitRLE n col ((count, v):(xs))
  | col'+count <= n = ((count, v):(splitRLE n (col'+count) xs))
  | otherwise = (remaining,v):(splitRLE n 0 ((count-remaining, v):xs))
  where col' = col `mod` n
        remaining = n - col'

rle :: Eq a => [a] -> [(Int, a)]
rle = map (\x -> (length x, head x)) . group
