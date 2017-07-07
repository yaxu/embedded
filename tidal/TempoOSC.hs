module Sound.Tidal.TempoOSC where

import Sound.OSC.FD
import Network.Socket


listen = udpServer iNADDR_ANY aNY_PORT

