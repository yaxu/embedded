import Sound.Tidal.Tempo

main = do putStrLn "cycle:"
          clocked onTick

onTick tempo tick = putStr $ show tick ++ "\r"
