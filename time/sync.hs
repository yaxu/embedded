import qualified Network.Socket as N
import qualified Sound.OSC.Transport.FD.UDP as O

set_udp_opt k v (O.UDP s) = N.setSocketOption s k v
get_udp_opt k (O.UDP s) = N.getSocketOption s k

main = do fd <- O.openUDP "127.0.0.1" 57110
          set_udp_opt N.Broadcast 1 fd
          O.sendOSC fd $ O.Message "/test" [string "1 2 3 4 5 8 9"]

