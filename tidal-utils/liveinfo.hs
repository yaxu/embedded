import Sound.Tidal.Tempo

main = clocked onTick

onTick tempo tick =
  putStr $ "cps: " ++ show (cps tempo) ++ " cycle: " ++ show tick ++ "   \r"
