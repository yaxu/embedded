module Sound.Tidal.WebSocket where

import Control.Exception (try)
import qualified Sound.Tidal.Context as Tidal
import qualified Sound.Tidal.Stream as Tidal
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as T
import qualified Network.WebSockets as WS
import Data.List
import Data.Ratio
import Data.Maybe

import Sound.Tidal.Hint
import Control.Concurrent.MVar

type TidalState = (Tidal.ParamPattern -> IO(), MVar [(WS.Connection, Tidal.ParamPattern)])

port = 9162

main = do
  putStrLn $ "TidalCycles websocket server, listening on port " ++ show port
  mPatterns <- newMVar []
  WS.runServer "0.0.0.0" port $ (\pending -> do
    conn <- WS.acceptRequest pending
    putStrLn "received new connection"
    WS.forkPingThread conn 30
    d <- Tidal.dirtStream
    loop (d, mPatterns) conn
    )

loop :: TidalState -> WS.Connection -> IO ()
loop state@(d, mPatterns) conn = do
  msg <- try (WS.receiveData conn)
  -- add to dictionary of connections -> patterns, could use a map for this
  modifyMVar_ mPatterns (\ps -> return ((conn, Tidal.silence):ps))
  case msg of
    Right s -> do
      act state conn (T.unpack s)
      loop state conn
    Left WS.ConnectionClosed -> close state "unexpected loss of connection"
    Left (WS.CloseRequest _ _) -> close state "by request from peer"
    Left (WS.ParseException e) -> close state ("parse exception: " ++ e)

close :: TidalState -> String -> IO ()
close (cps,dss) msg = do
  putStrLn ("connection closed: " ++ msg)
  -- hush dss

-- hush = mapM_ ($ Tidal.silence)

act :: TidalState -> WS.Connection -> String -> IO ()
act state conn request | isPrefixOf "/eval " request =
  do putStrLn (show request)
     let code = fromJust $ stripPrefix "/eval " request
     r <- runJob code
     case r of OK p -> do WS.sendTextData conn (T.pack "good.")
                          putStrLn "updating"
                          -- updatePat state (conn, p)
                          putStrLn "updated"
               Error s -> WS.sendTextData conn (T.pack $ "bad: " ++ s)
     return ()

act _ _ _ = return ()

updatePat :: TidalState -> (WS.Connection, Tidal.ParamPattern) -> IO ()
updatePat (d, mPatterns) (conn, p) =
  do pats <- takeMVar mPatterns
     let pats' = ((conn,p) : filter ((/= conn) . fst) pats)
         ps = map snd pats'
     putMVar mPatterns pats'
     d $ Tidal.stack ps
     return ()
     
{-
processRequest (_,dss) (Pattern n p) = do
  x <- hintParamPattern p
  case x of (Left error) -> do
              putStrLn "Error interpreting pattern"
              return Nothing
            (Right paramPattern) -> do
              dss!!(n-1) $ paramPattern
              return Nothing

processRequest _ (Render patt cps cycles) = do
  x <- hintParamPattern patt
  case x of (Left error) -> do
              putStrLn "Error interpreting pattern"
              return Nothing
            (Right paramPattern) -> do
              let r = render paramPattern cps cycles
              putStrLn (encodeStrict r)
              return (Just (showJSON r))
-}
