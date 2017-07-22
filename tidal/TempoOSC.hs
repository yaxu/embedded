module TempoOSC where

import Sound.OSC.FD
import qualified Network.Socket as N
import Safe (readNote)
import System.Environment (lookupEnv)
import qualified Control.Exception as E
import Data.Time (getCurrentTime, UTCTime, NominalDiffTime, diffUTCTime, addUTCTime)

data Tempo = Tempo {at :: UTCTime,
                    beat :: Double,
                    cps :: Double,
                    paused :: Bool,
                    clockLatency :: Double
                   }

instance Show Tempo where
  show x = (show (at x) ++ "," ++
            show (beat x) ++ "," ++
            show (cps x) ++ "," ++
            show (paused x) ++ ","
            ++ (show $ clockLatency x)
           )

getLatency :: IO Double
getLatency =
   maybe 0.04 (readNote "latency parse") <$> lookupEnv "TIDAL_CLOCK_LATENCY"

getClockIp :: IO String
getClockIp = fromMaybe "127.0.0.1" <$> lookupEnv "TIDAL_TEMPO_IP"

getServerPort :: IO Int
getServerPort =
   maybe 9160 (readNote "port parse") <$> lookupEnv "TIDAL_TEMPO_PORT"


runServer = do port <- getServerPort
               -- inaddr_any + any_port
               sock <- N.socket N.AF_INET N.Datagram 0
               -- N.setSocketOptiSocketon sock N.NoDelay 1
               N.setSocketOption sock N.ReuseAddr 1
               -- N.setSocketOption sock N.ReusePort 1
               a <- N.inet_addr "0.0.0.0"
               let sa = N.SockAddrInet (fromIntegral 6040) a
               N.bind sock sa
               let s = UDP sock
               serverLoop s []

client = do sock <- N.socket N.AF_INET N.Datagram 0
            -- N.setSocketOptiSocketon sock N.NoDelay 1
            N.setSocketOption sock N.Broadcast 1
            -- N.setSocketOption sock N.ReusePort 1
            a <- N.inet_addr "127.255.255.255"
            let sa = N.SockAddrInet (fromIntegral 6040) a
            N.connect sock sa
            let s = UDP sock
            return s

serverLoop s cs = do msgs <- recvMessages s
                     cs' <- process msgs cs
                     serverLoop s cs'
           where process [] cs = return cs
                 process (msg:msgs) cs = do putStrLn $ "received message" ++ (show msg)
                                            let address = messageAddress msg
                                            cs' <- act address msg cs
                                            process msgs cs'

                     
act "/join" msg cs = return cs

