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

import Data.Map

data Response = OK {parsed :: ParamPattern}
              | Error {errorMessage :: String}

instance (Show a) => Show (Response) where
  show (OK p) = "Ok: " ++ show p
  show (Error s) = "Error: " ++ s

runJob :: String -> IO (Response)
runJob job = do putStrLn $ "Parsing: " ++ job
                result <- hintParamPattern job
                let response = case result of
                      Left err -> Error (show err)
                      Right p -> OK p
                return response

libs = ["Prelude","Sound.Tidal.Context","Sound.OSC.Type","Sound.OSC.Datum","Data.Map"]

hintParamPattern  :: String -> IO (Either InterpreterError ParamPattern)
hintParamPattern s = Hint.runInterpreter $ do
  Hint.set [languageExtensions := [OverloadedStrings]]
  Hint.setImports libs
  Hint.interpret s (Hint.as :: ParamPattern)

