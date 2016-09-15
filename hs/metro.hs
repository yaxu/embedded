
include Sound.Tidal.Tempo

main = clocked $ \(tempo tick) -> putStr $ show tick ++ "\r"
