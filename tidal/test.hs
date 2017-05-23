{-# LANGUAGE OverloadedStrings #-}

import Sound.Tidal.Context

let x = fast 12 $ chunk 4 (fast 2) $ iter 4 ("bd bd bd" :: Pattern String)

main = putStrLn $ show $ length (arc x (0,1))
