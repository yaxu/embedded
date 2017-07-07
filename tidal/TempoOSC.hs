module Sound.Tidal.TempoOSC where

import Sound.OSC.FD
import Network.Socket

serverPort :: IO Int
serverPort =
   maybe 9160 (readNote "port parse") <$> lookupEnv "TIDAL_TEMPO_PORT"

listen = udpServer iNADDR_ANY aNY_PORT

runServer = do port <- serverPort
               s <- udpServer iNADDR_ANY port
               serverLoop s

serverLoop s = do msg <- recvMessage osc
                  putStrLn $ "received message" ++ (show msg)
                  let address = messageAddress msg
                  act address
                  serverLoop s
               
