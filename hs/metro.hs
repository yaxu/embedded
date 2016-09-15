import Sound.Tidal.Tempo

main = do putStr "\n"
          clocked onTick

onTick tempo tick = putStr $ show (cps tempo) ++ " " ++ show tick ++ "   \r"
