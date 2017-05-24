import Sound.Tidal.Context

x = fast 12 $ chunk 4 (fast 2) $ iter 4 y
y = (p "bd bd bd") :: Pattern String
main = putStrLn $ show $ length $ concatMap (\n -> arc x (n,n+0.25)) [0, 0.25, 0.5,0.75]
