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
              let rects = filter (\(_, _, _, v) -> v == 1) $ rleXY contents
              return ()
            surfaceWriteToPNG surf "test.png"


-- drawCells :: Int -> Int -> [(Int, Int)] -> IO ()
--           rectangle 0 0 100 100
--          fill

rleXY :: Eq a => Int -> [a] -> [(Int, Int, Int, a)]
rleXY cols [] = []
rleXY cols xs = map toxy $ rlepos 0 $ splitRLE cols 0 $ rle xs
  where rlepos pos ((count, v):xs) = ((pos, count, v):(rlepos (pos+count) xs))
        rlepos _ [] = []
        toxy (pos, count, v) = (pos `mod` cols, pos `div` cols, count, v)

splitRLE _ _  [] = []
splitRLE n col ((count, v):(xs))
  | col'+count <= n = ((count, v):(splitRLE n (col'+count) xs))
  | otherwise = (remaining,v):(splitRLE n 0 ((count-remaining, v):xs))
  where col' = col `mod` n
        remaining = n - col'

rle :: Eq a => [a] -> [(Int, a)]
rle = map (\x -> (length x, head x)) . group
