module TempoOSC where

import Sound.OSC.FD
import Network.Socket
import Safe (readNote)
import System.Environment (lookupEnv)

serverPort :: IO Int
serverPort =
   maybe 9160 (readNote "port parse") <$> lookupEnv "TIDAL_TEMPO_PORT"

listen = udpServer "0.0.0.0" aNY_PORT

runServer = do port <- serverPort
               s <- udpServer iNADDR_ANY port
               serverLoop s []

serverLoop s cs = do msg <- recvMessage osc
                     putStrLn $ "received message" ++ (show msg)
                     let address = messageAddress msg
                     cs' <- act address msg cs
                     serverLoop s cs'

  where act "/join" msg cs = return 
