module Node.Net.Types
  ( IpFamily(..)
  , toNodeIpFamily
  , unsafeFromNodeIpFamily
  , IPv4
  , IPv6
  , SocketAddress
  , BlockList
  , ConnectionType
  , TCP
  , IPC
  , Socket
  , SocketReadyState(..)
  , socketReadyStateToNode
  , Server
  , NewServerOptions
  , NewSocketOptions
  , ConnectTcpOptions
  , ConnectTcpOptionsFamilyOption -- constructor intentionally not exported
  , familyIpv4
  , familyIpv6
  , familyIpv4And6
  , ConnectIpcOptions
  , ListenTcpOptions
  , ListenIpcOptions
  ) where

import Prelude

import Data.Generic.Rep (class Generic)
import Data.Time.Duration (Milliseconds)
import Node.FS (FileDescriptor)
import Partial.Unsafe (unsafeCrashWith)

data IpFamily
  -- | Value-level constructor for the IPv4 ip family
  = IPv4
  -- | Value-level constructor for the IPv6 ip family
  | IPv6

derive instance Eq IpFamily
derive instance Ord IpFamily
derive instance Generic IpFamily _

instance Show IpFamily where
  show = case _ of
    IPv4 -> "IPv4"
    IPv6 -> "IPv6"

toNodeIpFamily :: IpFamily -> String
toNodeIpFamily = case _ of
  IPv4 -> "ipv4"
  IPv6 -> "ipv6"

unsafeFromNodeIpFamily :: String -> IpFamily
unsafeFromNodeIpFamily = case _ of
  "ipv4" -> IPv4
  "ipv6" -> IPv6
  "IPv4" -> IPv4
  "IPv6" -> IPv6
  x -> unsafeCrashWith $ "Impossible. Unknown ip family: " <> x

-- | Type-level tag for the IPv4 ip family
foreign import data IPv4 :: IpFamily
-- | Type-level tag for the IPv6 ip family
foreign import data IPv6 :: IpFamily

foreign import data SocketAddress :: IpFamily -> Type

foreign import data BlockList :: Type

data ConnectionType

foreign import data IPC :: ConnectionType
foreign import data TCP :: ConnectionType

-- | `Socket` extends `Duplex` and `EventEmitter`
foreign import data Socket :: ConnectionType -> Type

data SocketReadyState
  = Opening
  | Open
  | ReadOnly
  | WriteOnly

derive instance Eq SocketReadyState
derive instance Generic SocketReadyState _

socketReadyStateToNode :: SocketReadyState -> String
socketReadyStateToNode = case _ of
  Opening -> "opening"
  Open -> "open"
  ReadOnly -> "readOnly"
  WriteOnly -> "writeOnly"

-- | `Server` extends `EventEmitter`
foreign import data Server :: ConnectionType -> Type

-- | `allowHalfOpen` <boolean> If set to false, then the socket will automatically end the writable side when the readable side ends. Default: false.
-- | `pauseOnConnect` <boolean> Indicates whether the socket should be paused on incoming connections. Default: false.
-- | `noDelay` <boolean> If set to true, it disables the use of Nagle's algorithm immediately after a new incoming connection is received. Default: false.
-- | `keepAlive` <boolean> If set to true, it enables keep-alive functionality on the socket immediately after a new incoming connection is received, similarly on what is done in socket.setKeepAlive([enable][, initialDelay]). Default: false.
-- | `keepAliveInitialDelay` <number> If set to a positive number, it sets the initial delay before the first keepalive probe is sent on an idle socket.Default: 0.
type NewServerOptions r =
  ( allowHalfOpen :: Boolean
  , pauseOnConnect :: Boolean
  , noDelay :: Boolean
  , keepAlive :: Boolean
  , keepAliveInitialDelay :: Number
  | r
  )

-- | `fd` <number> If specified, wrap around an existing socket with the given file descriptor, otherwise a new socket will be created.
-- | `allowHalfOpen` <boolean> If set to false, then the socket will automatically end the writable side when the readable side ends. See net.createServer() and the 'end' event for details. Default: false.
-- | `readable` <boolean> Allow reads on the socket when an fd is passed, otherwise ignored. Default: false.
-- | `writable` <boolean> Allow writes on the socket when an fd is passed, otherwise ignored. Default: false.
type NewSocketOptions r =
  ( fd :: FileDescriptor
  , allowHalfOpen :: Boolean
  , readable :: Boolean
  , writable :: Boolean
  | r
  )

-- | `port` <number> Required. Port the socket should connect to.
-- | `host` <string> Host the socket should connect to. Default: 'localhost'.
-- | `localAddress` <string> Local address the socket should connect from.
-- | `localPort` <number> Local port the socket should connect from.
-- | `family` <number>: Version of IP stack. Must be 4, 6, or 0. The value 0 indicates that both IPv4 and IPv6 addresses are allowed. Default: 0.
-- | `noDelay` <boolean> If set to true, it disables the use of Nagle's algorithm immediately after the socket is established. Default: false.
-- | `keepAlive` <boolean> If set to true, it enables keep-alive functionality on the socket immediately after the connection is established, similarly on what is done in socket.setKeepAlive([enable][, initialDelay]). Default: false.
-- | `keepAliveInitialDelay` <number> If set to a positive number, it sets the initial delay before the first keepalive probe is sent on an idle socket.Default: 0.
-- | `autoSelectFamily` <boolean>: If set to true, it enables a family autodetection algorithm that loosely implements section 5 of RFC 8305. The all option passed to lookup is set to true and the sockets attempts to connect to all obtained IPv6 and IPv4 addresses, in sequence, until a connection is established. The first returned AAAA address is tried first, then the first returned A address and so on. Each connection attempt is given the amount of time specified by the autoSelectFamilyAttemptTimeout option before timing out and trying the next address. Ignored if the family option is not 0 or if localAddress is set. Connection errors are not emitted if at least one connection succeeds. Default: false.
-- | `autoSelectFamilyAttemptTimeout` <number>: The amount of time in milliseconds to wait for a connection attempt to finish before trying the next address when using the autoSelectFamily option. If set to a positive integer less than 10, then the value 10 will be used instead. Default: 250.
-- |
-- | Note: `hints` and `lookup` are not supported for now.
type ConnectTcpOptions r =
  ( port :: Int
  , host :: String
  , localAddress :: String
  , localPort :: Int
  , family :: ConnectTcpOptionsFamilyOption
  -- , hints :: number
  -- , lookup :: Function
  , noDelay :: Boolean
  , keepAlive :: Boolean
  , keepAliveInitialDelay :: Number
  , autoSelectFamily :: Boolean
  , autoSelectFamilyAttemptTimeout :: Milliseconds
  | r
  )

newtype ConnectTcpOptionsFamilyOption = ConnectTcpOptionsFamilyOption Int

derive instance Eq ConnectTcpOptionsFamilyOption

familyIpv4 :: ConnectTcpOptionsFamilyOption
familyIpv4 = ConnectTcpOptionsFamilyOption 4

familyIpv6 :: ConnectTcpOptionsFamilyOption
familyIpv6 = ConnectTcpOptionsFamilyOption 6

familyIpv4And6 :: ConnectTcpOptionsFamilyOption
familyIpv4And6 = ConnectTcpOptionsFamilyOption 0

type ConnectIpcOptions r =
  ( path :: String
  | r
  )

-- | port <number>
-- | host <string>
-- | backlog <number>  specifies the maximum length of the queue of pending connections. The actual length will be determined by the OS through sysctl settings such as tcp_max_syn_backlog and somaxconn on Linux. The default value of this parameter is 511 (not 512).
-- | exclusive <boolean> Default: false
-- | ipv6Only <boolean> For TCP servers, setting ipv6Only to true will disable dual-stack support, i.e., binding to host :: won't make 0.0.0.0 be bound. Default: false.
type ListenTcpOptions r =
  ( port :: Int
  , host :: String
  , backlog :: Int
  , exclusive :: Boolean
  , ipv6Only :: Boolean
  | r
  )

-- | host <string>
-- | path <string>
-- | backlog <number> specifies the maximum length of the queue of pending connections. The actual length will be determined by the OS through sysctl settings such as tcp_max_syn_backlog and somaxconn on Linux. The default value of this parameter is 511 (not 512).
-- | exclusive <boolean> Default: false
-- | readableAll <boolean> makes the pipe readable for all users. Default: false.
-- | writableAll <boolean> makes the pipe writable for all users. Default: false.
type ListenIpcOptions r =
  ( host :: String
  , path :: String
  , backlog :: Int
  , exclusive :: Boolean
  , readableAll :: Boolean
  , writableAll :: Boolean
  | r
  )
