module TempoOSC where

import Sound.OSC.FD
import Network.Socket
import Safe (readNote)
import System.Environment (lookupEnv)

serverPort :: IO Int
serverPort =
   maybe 9160 (readNote "port parse") <$> lookupEnv "TIDAL_TEMPO_PORT"

runServer = do port <- serverPort
               -- inaddr_any + any_port
               s <- udpServer "0.0.0.0" 0
               serverLoop s []

serverLoop s cs = do msgs <- recvMessages osc
                     cs' <- process msgs cs
                     serverLoop s cs'
           where process [] cs = return cs
                 process (msg:msgs) cs = do putStrLn $ "received message" ++ (show msg)
                                            let address = messageAddress msg
                                            cs' <- act address msg cs
                                            process msgs cs'

                     
act "/join" msg cs = return cs
