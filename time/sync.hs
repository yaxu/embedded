import qualified Network.Socket as N
import Sound.OSC.FD

set_udp_opt k v (UDP s) = N.setSocketOption s k v
get_udp_opt k (UDP s) = N.getSocketOption s k

main = do fd <- openUDP N.iNADDR_ANY N.aNY_PORT
          set_udp_opt N.Broadcast 1 fd
          sendOSC fd $ Message "/test" [string "1 2 3 4 5 8 9"]

