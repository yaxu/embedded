import System.IO
import Data.List
import Graphics.Rendering.Cairo
import System.IO
import System.Environment

w :: Int
w = 100

cellw = 12 :: Int
cellh = 12 :: Int
cols = (w `div` cellw)

main = do as <- getArgs
          handle <- openFile ((as !! 0) ++ ".txt") ReadMode
          let description = as !! 1
          contents <- hGetContents handle
          let things = rleXY cols contents
              h = ((length contents) `div` cols) * cellh + 1
          withSVGSurface ((as !! 0) ++ ".svg") (fromIntegral w) (fromIntegral h) $ \surf -> do
            renderWith surf $ do
              save
              setOperator OperatorOver
              setSourceRGB 1 1 1
              rectangle 0 0 (fromIntegral w) (fromIntegral h)
              fill
              setSourceRGB 0 0 0
              mapM_ drawThing $ filter (\(_, _, _, v) -> v == '1') things
              selectFontFace "Terminal Dosis" FontSlantNormal FontWeightNormal
              setFontSize 12
              textPath description
              fill
              restore
              return ()
          hClose handle

drawThing :: (Int, Int, Int, a) -> Render ()
drawThing (x,y,len,v) = do rectangle (fromIntegral $ x*cellw) (fromIntegral $ y*cellh) (fromIntegral $ cellw*len) (fromIntegral cellh)
                           fill
                           return ()


-- drawCells :: Int -> Int -> [(Int, Int)] -> IO ()
--           rectangle 0 0 100 100
--          fill

rleXY :: Eq a => Int -> [a] -> [(Int, Int, Int, a)]
rleXY n xs = toXY 0 $ splitRLE n 0 $ rle xs
  where toXY _ [] = []
        toXY i ((col,v):xs) = (i `mod` n, i `div` n, col, v):(toXY (i+col) xs)

splitRLE _ _ [] = []
splitRLE n col ((count, v):(xs))
  | col'+count <= n = ((count, v):(splitRLE n (col'+count) xs))
  | otherwise = (remaining,v):(splitRLE n 0 ((count-remaining, v):xs))
  where col' = col `mod` n
        remaining = n - col'

rle :: Eq a => [a] -> [(Int, a)]
rle = map (\x -> (length x, head x)) . group
