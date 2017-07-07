module Sound.Tidal.TempoOSC where

import Sound.OSC.FD
import Network.Socket

serverPort :: IO Int
serverPort =
   maybe 9160 (readNote "port parse") <$> lookupEnv "TIDAL_TEMPO_PORT"

listen = udpServer iNADDR_ANY aNY_PORT

server = do udpServer iNADDR_ANY 
