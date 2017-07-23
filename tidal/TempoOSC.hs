module TempoOSC where

import Sound.OSC.FD
import qualified Network.Socket as N
import Safe (readNote)
import System.Environment (lookupEnv)
import qualified Control.Exception as E
import Data.Time (getCurrentTime, UTCTime, NominalDiffTime, diffUTCTime, addUTCTime)
import Data.Time.Clock.POSIX
import Data.Maybe
import Control.Concurrent.MVar
import Control.Concurrent

data Tempo = Tempo {at :: UTCTime,
                    beat :: Double,
                    cps :: Double,
                    paused :: Bool
                   }

instance Show Tempo where
  show x = (show (at x) ++ "," ++
            show (beat x) ++ "," ++
            show (cps x) ++ "," ++
            show (paused x)
           )

getClockIp :: IO String
getClockIp = fromMaybe "127.0.0.1" <$> lookupEnv "TIDAL_TEMPO_IP"

getServerPort :: IO Int
getServerPort =
   maybe 9160 (readNote "port parse") <$> lookupEnv "TIDAL_TEMPO_PORT"


tempoReceiver = do
                   mTempo <- newEmptyMVar 
                   mCps <- newEmptyMVar 
                   mNudge <- newEmptyMVar 
                   port <- getServerPort
                   -- inaddr_any + any_port
                   sock <- N.socket N.AF_INET N.Datagram 0
                   -- N.setSocketOptiSocketon sock N.NoDelay 1
                   N.setSocketOption sock N.ReuseAddr 1
                   -- N.setSocketOption sock N.ReusePort 1
                   a <- N.inet_addr "0.0.0.0"
                   let sa = N.SockAddrInet (fromIntegral 6040) a
                   N.bind sock sa
                   let s = UDP sock
                   forkIO $ tempoReceiverLoop s (mTempo, mCps, mNudge)
                   putStrLn "good."
                   return (mTempo, mCps, mNudge)


tempoReceiverLoop s mvs =
  do b <- recvBundle s
     let timestamp = addUTCTime (realToFrac $ ntpr_to_ut $ bundleTime b) ut_epoch
     mapM_ (process mvs timestamp) (bundleMessages b)
     tempoReceiverLoop s mvs
       where process mvs timestamp m =
               do putStrLn $ "received message" ++ (show m)
                  let address = messageAddress m
                  act address mvs timestamp m

act "/tempo" mvs timestamp m = return ()
{-
  where t = Tempo {at = timestamp,
                   beat = datum_floating $ (messageDatum m) !! 0,
                   cps = datum_floating $ (messageDatum m) !! 1,
                   paused = False
                  }
-}
client = do sock <- N.socket N.AF_INET N.Datagram 0
            -- N.setSocketOptiSocketon sock N.NoDelay 1
            N.setSocketOption sock N.Broadcast 1
            -- N.setSocketOption sock N.ReusePort 1
            a <- N.inet_addr "127.255.255.255"
            let sa = N.SockAddrInet (fromIntegral 6040) a
            N.connect sock sa
            let s = UDP sock
            return s

sendTempo :: UDP -> Tempo -> IO ()
sendTempo sock t = sendOSC sock b
  where m = Message "/tempo" [float (realToFrac $ beat t),
                              float (realToFrac $ cps t),
                              string (show $ paused t)
                             ]
        b = Bundle (ut_to_ntpr $ utc_to_ut $ at t) [m]

logicalTime :: Tempo -> Double -> Double
logicalTime t b = changeT + timeDelta
  where beatDelta = b - (beat t)
        timeDelta = beatDelta / (cps t)
        changeT = realToFrac $ utcTimeToPOSIXSeconds $ at t

{-
tempoMVar :: IO (MVar (Tempo))
tempoMVar = do now <- getCurrentTime
               mv <- newMVar (Tempo now 0 0.5 False)
               forkIO $ clocked $ f mv
               return mv
  where f mv change _ = do swapMVar mv change
                           return ()
-}

beatNow :: Tempo -> IO (Double)
beatNow t = do now <- getCurrentTime
               let delta = realToFrac $ diffUTCTime now (at t)
               let beatDelta = cps t * delta               
               return $ beat t + beatDelta

clockedTick :: Int -> (Tempo -> Int -> IO ()) -> IO ()
clockedTick tpb callback = 
  do (mTempo, _, _) <- tempoReceiver
     t <- readMVar mTempo
     now <- getCurrentTime
     let delta = realToFrac $ diffUTCTime now (at t)
         beatDelta = cps t * delta
         nowBeat = beat t + beatDelta
         nextTick = ceiling (nowBeat * (fromIntegral tpb))
     loop mTempo nextTick
  where loop mTempo tick = 
          do tempo <- readMVar mTempo
             tick' <- doTick tempo tick
             loop mTempo tick'
        doTick tempo tick | paused tempo =
          do let pause = 0.01
             -- TODO - do this via blocking read on the mvar somehow
             -- rather than polling
             threadDelay $ floor (pause * 1000000)
             -- reset tick to 0 if cps is negative
             return $ if cps tempo < 0 then 0 else tick
                          | otherwise =
          do now <- getCurrentTime
             let tps = (fromIntegral tpb) * cps tempo
                 delta = realToFrac $ diffUTCTime now (at tempo)
                 actualTick = ((fromIntegral tpb) * beat tempo) + (tps * delta)
                 -- only wait by up to two ticks
                 tickDelta = min 2 $ (fromIntegral tick) - actualTick
                 delay = tickDelta / tps
             threadDelay $ floor (delay * 1000000)
             callback tempo tick
             let newTick | (abs $ (floor actualTick) - tick) > 4 = floor actualTick
                         | otherwise = tick + 1
             return $ newTick

