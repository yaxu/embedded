
include Sound.Tidal.Tempo

main = do putStrLn "cycle:"
          clocked $ \tempo tick -> putStr $ show tick ++ "\r"
