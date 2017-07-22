module TempoOSC where

import Sound.OSC.FD
import qualified Network.Socket as N
import Safe (readNote)
import System.Environment (lookupEnv)
import qualified Control.Exception as E


serverPort :: IO Int
serverPort =
   maybe 9160 (readNote "port parse") <$> lookupEnv "TIDAL_TEMPO_PORT"

runServer = do port <- serverPort
               -- inaddr_any + any_port
               sock <- N.socket N.AF_INET N.Datagram 0
               -- N.setSocketOptiSocketon sock N.NoDelay 1
               -- N.setSocketOption sock N.ReuseAddr 1
               N.setSocketOption sock N.ReusePort 1
               a <- N.inet_addr "0.0.0.0"
               let sa = N.SockAddrInet (fromIntegral port) a
               N.bind sock sa
               let s = UDP sock
               serverLoop s []

serverLoop s cs = do msgs <- recvMessages s
                     cs' <- process msgs cs
                     serverLoop s cs'
           where process [] cs = return cs
                 process (msg:msgs) cs = do putStrLn $ "received message" ++ (show msg)
                                            let address = messageAddress msg
                                            cs' <- act address msg cs
                                            process msgs cs'

                     
act "/join" msg cs = return cs

{-
myk <- dirtStream
192.168.42.50

x <- udpServer "0.0.0.0" 4040

xx <- openUDP "92.51.149.243" 90930

(sendOSC xx $ Message "/tidal" [string "1 2 3 4 5 8 9"])
  `E.catch` \(_ :: E.SomeException) -> putStrLn "aha"
-}
