import System.IO
import Data.List
import Graphics.Rendering.Cairo
import System.IO
import System.Environment

w :: Int
<<<<<<< HEAD
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
=======
w = 100

cellw = 4 :: Int
cellh = 4 :: Int
cols = (w `div` cellw)

main = do as <- getArgs
          handle <- openFile ((as !! 0) ++ ".txt") ReadMode
          contents <- hGetContents handle
          let things = rleXY cols contents
              h = ((length contents) `div` cols) * cellh + 1
          withPDFSurface ((as !! 0) ++ ".pdf") (fromIntegral w) (fromIntegral h) $ \surf -> do
>>>>>>> b1dd8507f2f25ddcc33a23165fdfad698f8b1e24
            renderWith surf $ do
              setOperator OperatorOver
              setSourceRGB 1 1 1
              rectangle 0 0 (fromIntegral w) (fromIntegral h)
              fill
              setSourceRGB 0 0 0
<<<<<<< HEAD
              let rects = filter (\(_, _, _, v) -> v == '1') $ rleXY cols contents
              mapM_ (\(x,y,l,_) -> rectangle (cellw* (fromIntegral $ x)) (cellh* (fromIntegral y)) (cellh) (cellw*(fromIntegral l))) rects
              return ()
            surfaceWriteToPNG surf "test.png"
=======
              mapM_ drawThing $ filter (\(_, _, _, v) -> v == '1') things
              return ()
          hClose handle

drawThing :: (Int, Int, Int, a) -> Render ()
drawThing (x,y,len,v) = do rectangle (fromIntegral $ x*cellw) (fromIntegral $ y*cellh) (fromIntegral $ cellw*len) (fromIntegral cellh)
                           fill
                           return ()
>>>>>>> b1dd8507f2f25ddcc33a23165fdfad698f8b1e24


-- drawCells :: Int -> Int -> [(Int, Int)] -> IO ()
--           rectangle 0 0 100 100
--          fill

rleXY :: Eq a => Int -> [a] -> [(Int, Int, Int, a)]
<<<<<<< HEAD
rleXY cols [] = []
rleXY cols xs = map toxy $ rlepos 0 $ splitRLE cols 0 $ rle xs
  where rlepos pos ((count, v):xs) = ((pos, count, v):(rlepos (pos+count) xs))
        rlepos _ [] = []
        toxy (pos, count, v) = (pos `mod` cols, pos `div` cols, count, v)

splitRLE _ _  [] = []
=======
rleXY n xs = toXY 0 $ splitRLE n 0 $ rle xs
  where toXY _ [] = []
        toXY i ((col,v):xs) = (i `mod` n, i `div` n, col, v):(toXY (i+col) xs)

splitRLE _ _ [] = []
>>>>>>> b1dd8507f2f25ddcc33a23165fdfad698f8b1e24
splitRLE n col ((count, v):(xs))
  | col'+count <= n = ((count, v):(splitRLE n (col'+count) xs))
  | otherwise = (remaining,v):(splitRLE n 0 ((count-remaining, v):xs))
  where col' = col `mod` n
        remaining = n - col'

rle :: Eq a => [a] -> [(Int, a)]
rle = map (\x -> (length x, head x)) . group
