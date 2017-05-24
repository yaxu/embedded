import Sound.Tidal.Context

x = fast 12 $ chunk 4 (fast 2) $ iter 4 y
y = (p "bd bd bd") :: Pattern String
main = putStrLn $ show $ length (arc x (0,1))
