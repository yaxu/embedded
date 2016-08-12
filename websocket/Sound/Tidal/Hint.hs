module Sound.Tidal.Hint where

import Sound.Tidal.Context


import Language.Haskell.Interpreter as Hint

{-import Control.Monad
import Control.Concurrent
import Control.Concurrent.MVar
import Language.Haskell.Interpreter
import Sound.OSC.FD
import Sound.OSC.Datum

import Sound.Tidal.Stream
import Sound.Tidal.Pattern
import qualified Texture.Types as T
import Data.Colour
import Data.Colour.Names
import Data.Colour.SRGB
import Data.Hashable
import Data.Bits
import Data.Maybe
import Sound.Tidal.Dirt
import Sound.Tidal.OscStream
import qualified Data.Map as Map
import Control.Applicative
import qualified Data.ByteString.Char8 as C

import Data.Typeable
deriving instance Typeable Param
-- deriving instance Typeable1 Pattern
deriving instance Typeable Sound.OSC.FD.Datum
-}

data Response = OK {parsed :: ParamPattern}
              | Error {errorMessage :: String}

runJob :: String -> IO (Response)
runJob job = do result <- hintParamPattern
                let response = case result of
                      Left err -> Error job $ show err
                      Right p -> OK p
                return response

libs = [("Prelude", Nothing), 
        ("Sound.Tidal.Context", Nothing),
        ("Data.Map", Nothing),
        ("Control.Applicative", Nothing)
       ]

hintParamPattern  :: String -> IO (Either InterpreterError ParamPattern)
hintParamPattern s = Hint.runInterpreter $ do
  Hint.set [languageExtensions := [OverloadedStrings]]
  Hint.setImportsQ libs
  Hint.Interpret s (Hint.as :: ParamPattern)


runI :: Job -> Interpreter (ParamPattern)
runI input oscOut colourOut =
    do
      --loadModules ["Stream.hs"]
      --setTopLevelModules ["SomeModule"]
      setImportsQ libs
      loop
  where loop = do 
          thing <- liftIO (takeMVar input)
          --say =<< Language.Haskell.Interpreter.typeOf expr
          doJob thing
          loop
        doJob (OscJob code) = do -- say ("interpreting: " ++ code)
                                 p <- interpret code (as :: (ParamPattern))
                                 liftIO $ swapMVar oscOut p
                                 return ()
        doJob (ColourJob t code) = do -- say $ "interpreting: " ++ code ++ " type " ++ (show t)
                                      p <- interpretPat t code
                                      -- say $ " as colour pattern: " ++ (show p)
                                      liftIO $ putMVar colourOut p
                                      return ()


{-
run2 :: String -> Interpreter (Pattern (Colour Double))
run2 input output =
    do
      --loadModules ["Stream.hs"]
      --setTopLevelModules ["SomeModule"]
      
      setImportsQ libs
      loop
  where loop = do 
          expr <- liftIO (takeMVar input)
          say =<< Language.Haskell.Interpreter.typeOf expr

          p <- interpret expr (as :: (ParamPattern))
          say (show p)
          liftIO $ swapMVar output p
          loop
-}

say :: String -> Interpreter ()
say = liftIO . putStrLn

printInterpreterError :: InterpreterError -> IO ()
printInterpreterError e = putStrLn $ "Oops. " ++ (show e)

interpretPat :: T.Type -> String -> Interpreter (Maybe (Pattern (Colour Double)))

interpretPat T.String code = 
  do p <- interpret code (as :: Pattern String)
     return $ Just $ fmap stringToColour p

interpretPat T.Float code =
  do p <- interpret code (as :: Pattern Double)
     return $ Just $ fmap (stringToColour . show) p

interpretPat T.Osc code =
  do p <- interpret code (as :: (ParamPattern))
     return $ Just $ stringToColour <$> unosc p

interpretPat _ _ = return Nothing

unosc :: Pattern (Map.Map Param (Maybe Datum)) -> Pattern String
unosc p = (\x -> fromMaybe (show x) (soundString x)) <$> p

soundString :: Map.Map Param (Maybe Datum) -> Maybe [Char]
soundString o = do m <- Map.lookup (S "sound" Nothing) o
                   s <- m
                   -- hack to turn ASCII into String
                   return $ tail $ init $ show $ d_ascii_string s


{-
stringToColour :: String -> Colour Double
stringToColour s = sRGB (r/256) (g/256) (b/256)
  where i = (hash s) `mod` 16777216
        r = fromIntegral $ (i .&. 0xFF0000) `shiftR` 16;
        g = fromIntegral $ (i .&. 0x00FF00) `shiftR` 8;
        b = fromIntegral $ (i .&. 0x0000FF);
-}
