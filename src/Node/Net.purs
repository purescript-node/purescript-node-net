module Node.Net
  ( Address
  , ConnectOptions
  , ListenOptions
  , Lookup
  , Server
  , ServerOptions
  , Socket
  , SocketOptions
  , address
  , bufferSize
  , bytesRead
  , bytesWritten
  , close
  , connect
  , connectFamily
  , connectHints
  , connectHost
  , connectICP
  , connectLocalAddress
  , connectLocalPort
  , connectPath
  , connectPort
  , connectTCP
  , connecting
  , createConnection
  , createConnectionICP
  , createConnectionTCP
  , createServer
  , destroy
  , destroyed
  , end
  , endString
  , getConnections
  , isIP
  , isIPv4
  , isIPv6
  , listen
  , listenBacklog
  , listenExclusive
  , listenHost
  , listenICP
  , listenIpv6Only
  , listenPath
  , listenPort
  , listenReadableAll
  , listenTCP
  , listenWritableAll
  , listening
  , localAddress
  , localPort
  , onCloseServer
  , onCloseSocket
  , onConnect
  , onConnection
  , onData
  , onDrain
  , onEnd
  , onErrorServer
  , onErrorSocket
  , onListening
  , onLookup
  , onReady
  , onTimeout
  , pause
  , pending
  , remoteAddress
  , remoteFamily
  , remotePort
  , resume
  , serverAllowHalfOpen
  , serverPauseOnConnect
  , setEncoding
  , setKeepAlive
  , setNoDelay
  , setTimeout
  , socketAllowHalfOpen
  , socketFd
  , socketHost
  , socketPath
  , socketPort
  , socketReadable
  , socketTimeout
  , socketWritable
  , write
  , writeString
  ) where

import Prelude

import Control.Alt ((<|>))
import Control.Monad.Except (runExcept)
import Data.Either (Either(..), either)
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable, toMaybe, toNullable)
import Data.Options (Option, Options, opt, options, (:=))
import Effect (Effect)
import Effect.Exception (Error)
import Foreign (F, Foreign, readInt, readString)
import Foreign.Index (readProp)
import Node.Buffer (Buffer)
import Node.Encoding (Encoding)
import Node.FS (FileDescriptor)

type Address
  = { address :: String
    , family :: String
    , port :: Int
    }

-- | Options to configure the connecting side of a `Socket`.
-- | These options decide whether the `Socket` is ICP or TCP.
-- |
-- | One of `path` or `port` must be set.
-- | Setting `path` will make the `Socket` ICP.
-- | Setting `port` will make the `Socket` TCP.
data ConnectOptions

-- | Options to configure the listening side of a `Server`.
-- | These options decide whether the `Server` is ICP or TCP.
-- |
-- | One of `path` or `port` must be set.
-- | Setting `path` will make the `Server` ICP.
-- | Setting `port` will make the `Server` TCP.
data ListenOptions

type Lookup
  = { address :: String
    , family :: Maybe String
    , host :: String
    }

-- | An ICP or TCP server.
foreign import data Server :: Type

-- | Options to configure the basics of a `Server`.
data ServerOptions

-- | An ICP endpoint or TCP socket.
foreign import data Socket :: Type

-- | Options to configure the basics of a `Socket`.
data SocketOptions

foreign import addressImpl :: Server -> Effect (Nullable Foreign)

-- | Attempts to return the bound address of a `Server`.
-- |
-- | If the `Server` is not listening, no `Nothing` is returned.
-- | If the `Server` is ICP, it will return a `String`.
-- | If the `Server` is TCP, it will return an `Address`.
address :: Server -> Effect (Maybe (Either Address String))
address server = ado
  x <- addressImpl server
  in toMaybe x >>= read
  where
  hush :: F ~> Maybe
  hush f = either (\_ -> Nothing) Just (runExcept f)
  read :: Foreign -> Maybe (Either Address String)
  read value =
    hush (map Left $ readAddress value)
      <|> hush (map Right $ readString value)
  readAddress :: Foreign -> F Address
  readAddress value = ado
    address <- readProp "address" value >>= readString
    family <- readProp "family" value >>= readString
    port <- readProp "port" value >>= readInt
    in { address, family, port }

foreign import bufferSizeImpl :: Socket -> Effect (Nullable Int)

-- | The number of characters buffered to be written on a `Socket`.
-- |
-- | N.B. The number of characters is not equal to the number of bytes.
bufferSize :: Socket -> Effect (Maybe Int)
bufferSize socket = ado
  size <- bufferSizeImpl socket
  in toMaybe size

-- | The number of bytes recieved on the `Socket`.
foreign import bytesRead :: Socket -> Effect Int

-- | The number of bytes sent on the `Socket`.
foreign import bytesWritten :: Socket -> Effect Int

foreign import closeImpl :: Server -> (Nullable Error -> Effect Unit) -> Effect Unit

-- | Closes the `Server` and invokes the callback after the `'close'` event
-- | is emitted.
-- | An `Error` is passed to the callback if the `Server` was not open.
close :: Server -> (Maybe Error -> Effect Unit) -> Effect Unit
close server callback = closeImpl server \err -> callback (toMaybe err)

foreign import connectImpl :: Socket -> Foreign -> Effect Unit -> Effect Unit

-- | Creates a custom ICP or TCP connection on the `Socket`.
-- | Normally, `createConnection` should be used to create the socket.
connect :: Socket -> Options ConnectOptions -> Effect Unit -> Effect Unit
connect socket opts = connectImpl socket (options opts)

-- | Version of IP stack, either `4` or `6`.
-- | Defaults to `4`.
connectFamily :: Option ConnectOptions Int
connectFamily = opt "family"

-- | DNS lookup hints.
connectHints :: Option ConnectOptions Int
connectHints = opt "hints"

-- | The host to configure TCP `Socket`s.
-- |
-- | Determines the host the `Socket` will attempt to connect to.
-- | Defaults to `localhost`.
connectHost :: Option ConnectOptions String
connectHost = opt "host"

-- | Creates a custom ICP connection on the `Socket`.
-- | Normally, `createConnectionICP` should be used to create the socket.
connectICP :: Socket -> String -> Effect Unit -> Effect Unit
connectICP socket path =
  connectImpl socket (options $ connectPath := path)

-- | Address the `Socket` should connect from.
connectLocalAddress :: Option ConnectOptions String
connectLocalAddress = opt "localAddress"

-- | Port the `Socket` should connect from.
connectLocalPort :: Option ConnectOptions Int
connectLocalPort = opt "localPort"

-- | The path to configure ICP `Socket`s.
-- |
-- | Determines the ICP endpoint the `Socket` will attempt to connect to.
connectPath :: Option ConnectOptions String
connectPath = opt "path"

-- | The port to configure TCP `Server`s.
-- |
-- | Determines the TCP endpoint the `Server` will attempt to listen on.
connectPort :: Option ConnectOptions Int
connectPort = opt "port"

-- | Creates a custom TCP connection on the `Socket`.
-- | Normally, `createConnectionTCP` should be used to create the socket.
connectTCP :: Socket -> Int -> String -> Effect Unit -> Effect Unit
connectTCP socket port host =
  connectImpl socket (options $ connectHost := host <> connectPort := port)

-- | Returns `true` if `connect` was called, but the `'connect'` event hasn't
-- | been emitted yet.
-- | Returns `false` any other time.
foreign import connecting :: Socket -> Effect Boolean

foreign import createConnectionImpl :: Foreign -> Effect Unit -> Effect Socket

-- | Creates an ICP or TCP `Socket`, initiates a connection,
-- | returns the `Socket`, adds the callback as a one-time listener for the
-- | `'connect'` event, and emits the `'connect'` event.
createConnection :: Options SocketOptions -> Effect Unit -> Effect Socket
createConnection opts = createConnectionImpl (options opts)

-- | Creates an ICP `Socket`, initiates a connection,
-- | returns the `Socket`, adds the callback as a one-time listener for the
-- | `'connect'` event, and emits the `'connect'` event.
createConnectionICP :: String -> Effect Unit -> Effect Socket
createConnectionICP path =
  createConnectionImpl (options $ socketPath := path)

-- | Creates a TCP `Socket`, initiates a connection,
-- | returns the `Socket`, adds the callback as a one-time listener for the
-- | `'connect'` event, and emits the `'connect'` event.
createConnectionTCP :: Int -> String -> Effect Unit -> Effect Socket
createConnectionTCP port host =
  createConnectionImpl (options $ socketHost := host <> socketPort := port)

foreign import createServerImpl :: Foreign -> (Socket -> Effect Unit) -> Effect Server

-- | Creates an ICP or TCP `Server`, returns the `Server`,
-- | and adds the callback as a listenter for the `'connection'` event.
-- | the `Server` will be ICP or TCP depending on what it `listen`s to.
createServer :: Options ServerOptions -> (Socket -> Effect Unit) -> Effect Server
createServer opts = createServerImpl (options opts)

foreign import destroyImpl :: Socket -> Nullable Error -> Effect Unit

-- | Ensure no more I/O activity happens on the socket.
-- |
-- | If an `Error` is provided, an `'error'` event is emitted.
destroy :: Socket -> Maybe Error -> Effect Unit
destroy socket err = destroyImpl socket (toNullable err)

-- | Returns `true` if the connection is destroyed and can no longer transfer
-- | data.
foreign import destroyed :: Socket -> Effect Boolean

-- | Send a `FIN` packet to half-close the `Socket`.
-- | The server might still send more data.
-- | Invokes the callback after the `Socket` is finished.
foreign import end :: Socket -> Buffer -> Effect Unit -> Effect Unit

-- | Send a `FIN` packet to half-close the `Socket`.
-- | The server might still send more data.
-- | Invokes the callback after the `Socket` is finished.
foreign import endString :: Socket -> String -> Encoding -> Effect Unit -> Effect Unit

foreign import getConnectionsImpl :: Server -> (Nullable Error -> Nullable Int -> Effect Unit) -> Effect Unit

-- | Returns the number of concurrent connections to the `Server`.
getConnections :: Server -> (Either Error Int -> Effect Unit) -> Effect Unit
getConnections server callback = getConnectionsImpl server \err' count' ->
  case toMaybe err', toMaybe count' of
    Just err, _ -> callback (Left err)
    _, Just count -> callback (Right count)
    _, _ -> mempty

-- | Returns `4` if the `String` is a valid IPv4 address, `6` if the `String`
-- | is a valid IPv6 address, and `0` otherwise.
foreign import isIP :: String -> Int

-- | Returns `true` if the `String` is a valid IPv4 address,
-- | and `false` otherwise.
foreign import isIPv4 :: String -> Boolean

-- | Returns `true` if the `String` is a valid IPv4 address,
-- | and `false` otherwise.
foreign import isIPv6 :: String -> Boolean

foreign import listenImpl :: Server -> Foreign -> Effect Unit -> Effect Unit

-- | Starts the `Server` as an ICP or TCP `Server` listening for connections,
-- | adds the callback as a listener to the `'listening'` event, and emits the
-- | `'listening'` event.
listen :: Server -> Options ListenOptions -> Effect Unit -> Effect Unit
listen server opts = listenImpl server (options opts)

-- | Maximum number of pending connections.
-- | Defaults to `511`.
listenBacklog :: Option ListenOptions Int
listenBacklog = opt "backlog"

-- | When `true`, the handle cannot be shared and will result in an error.
-- | When `false`, the handle can be shared.
-- | Defaults to `false`.
listenExclusive :: Option ListenOptions Boolean
listenExclusive = opt "exclusive"

-- | The host to configure TCP `Server`s.
-- |
-- | Determines the host the `Server` will attempt to listen on.
-- | Defaults to IPv6 `::` if available, and IPv4 `0.0.0.0` otherwise.
listenHost :: Option ListenOptions String
listenHost = opt "host"

-- | Starts the `Server` as an ICP `Server` listening for connections,
-- | adds the callback as a listener to the `'listening'` event, and emits the
-- | `'listening'` event.
listenICP :: Server -> String -> Int -> Effect Unit -> Effect Unit
listenICP server path backlog =
  listenImpl server (options $ listenBacklog := backlog <> listenPath := path)

-- | When `true`, only binds to IPv6 hosts and not also to IPv4 hosts.
-- | Defaults to `false`.
listenIpv6Only :: Option ListenOptions Boolean
listenIpv6Only = opt "ipv6Only"

-- | The path to configure ICP `Server`s.
-- |
-- | Determines the ICP endpoint the `Server` will attempt to listen on.
listenPath :: Option ListenOptions String
listenPath = opt "path"

-- | The port to configure TCP `Server`s.
-- |
-- | Determines the TCP endpoint the `Server` will attempt to listen on.
-- | When `0`, the OS will assign an arbitrary port.
listenPort :: Option ListenOptions Int
listenPort = opt "port"

-- | Makes the ICP pipe readable for all users.
-- | Defaults to `false`.
listenReadableAll :: Option ListenOptions Boolean
listenReadableAll = opt "readableAll"

-- | Starts the `Server` as a TCP `Server` listening for connections,
-- | adds the callback as a listener to the `'listening'` event, and emits the
-- | `'listening'` event.
listenTCP :: Server -> Int -> String -> Int -> Effect Unit -> Effect Unit
listenTCP server port host backlog =
  listenImpl server (options $ listenBacklog := backlog <> listenHost := host <> listenPort := port)

-- | Makes the ICP pipe writable for all users.
-- | Defaults to `false`.
listenWritableAll :: Option ListenOptions Boolean
listenWritableAll = opt "writableAll"

-- | Returns `true` if the `Server` is listening for connections, and `false`
-- | otherwise.
foreign import listening :: Server -> Effect Boolean

foreign import localAddressImpl :: Socket -> Effect (Nullable String)

-- | Attempts to return the address a client is connecting on.
-- | E.g. if a client connects from `192.168.1.1`,
-- | the result would be `Just "192.168.1.1"`.
localAddress :: Socket -> Effect (Maybe String)
localAddress socket = ado
  address <- localAddressImpl socket
  in toMaybe address

foreign import localPortImpl :: Socket -> Effect (Nullable Int)

-- | Attempts to return the port a client is connecting on.
-- | E.g. if a client connects from `80`,
-- | the result would be `Just "80"`.
localPort :: Socket -> Effect (Maybe Int)
localPort socket = ado
  port <- localPortImpl socket
  in toMaybe port

-- | Attaches the callback as a listener to the `'close'` event.
-- |
-- | `'close'` is emitted when a close occurs.
-- | Will not be emitted until all connections have ended.
foreign import onCloseServer :: Server -> Effect Unit -> Effect Unit

-- | Attaches the callback as a listener to the `'close'` event.
-- | The `Boolean` represents whether an error happened during transmission.
-- |
-- | `'close'` is emitted when an close occurs.
foreign import onCloseSocket :: Socket -> (Boolean -> Effect Unit) -> Effect Unit

-- | Attaches the callback as a listener to the `'connect'` event.
-- |
-- | `'connect'` is emitted when a new connection is successfully establed.
foreign import onConnect :: Socket -> Effect Unit -> Effect Unit

-- | Attaches the callback as a listener to the `'connection'` event.
-- |
-- | `'connection'` is emitted when a new connection is made.
foreign import onConnection :: Server -> (Socket -> Effect Unit) -> Effect Unit

foreign import onDataImpl :: Socket -> (Buffer -> Effect Unit) -> (String -> Effect Unit) -> Effect Unit

-- | Attaches the callback as a listener to the `'data'` event.
-- |
-- | `'data'` is emitted when a data is recieved.
-- | Data will be lost if there is no listener when `'data'` is emitted.
onData :: Socket -> (Either Buffer String -> Effect Unit) -> Effect Unit
onData socket callback =
  onDataImpl socket (callback <<< Left) (callback <<< Right)

-- | Attaches the callback as a listener to the `'drain'` event.
-- |
-- | `'drain'` is emitted when the write buffer is empty.
foreign import onDrain :: Socket -> Effect Unit -> Effect Boolean

-- | Attaches the callback as a listener to the `'end'` event.
-- |
-- | `'end'` is emitted when the other end of the `Socket` sends a `FIN` packet.
foreign import onEnd :: Socket -> Effect Unit -> Effect Unit

-- | Attaches the callback as a listener to the `'error'` event.
-- |
-- | `'error'` is emitted when an error occurs.
foreign import onErrorServer :: Server -> (Error -> Effect Unit) -> Effect Unit

-- | Attaches the callback as a listener to the `'error'` event.
-- |
-- | `'error'` is emitted when an error occurs.
-- | `'close'` is emitted directly after this event.
foreign import onErrorSocket :: Socket -> (Error -> Effect Unit) -> Effect Unit

-- | Attaches the callback as a listener to the `'listening'` event.
-- |
-- | `'listening'` is emitted when the `Server` has been bound.
foreign import onListening :: Server -> Effect Unit -> Effect Unit

foreign import onLookupImpl :: Socket -> (Nullable Error -> Nullable String -> Nullable (Nullable String) -> Nullable String -> Effect Unit) -> Effect Unit

-- | Attaches the callback as a listener to the `'lookup'` event.
-- |
-- | `'lookup'` is emitted after resolving the hostname but before connecting.
onLookup :: Socket -> (Either Error Lookup -> Effect Unit) -> Effect Unit
onLookup socket callback = onLookupImpl socket \err' address'' family' host' ->
  case toMaybe err', toMaybe address'', toMaybe family', toMaybe host' of
    Just err, _, _, _ -> callback (Left err)
    Nothing, Just address', Just family, Just host ->
      callback (Right { address: address', family: toMaybe family, host })
    _, _, _, _ -> mempty

-- | Attaches the callback as a listener to the `'ready'` event.
-- |
-- | `'ready'` is emitted when the `Socket` is ready to be used.
foreign import onReady :: Socket -> Effect Unit -> Effect Unit

-- | Attaches the callback as a listener to the `'timeout'` event.
-- |
-- | `'timeout'` is emitted if the `Socket` times out from inactivity.
-- | The `Socket` is still open and should be manually closed.
foreign import onTimeout :: Socket -> Effect Unit -> Effect Unit

-- | Pauses `'data'` events from being emitted.
foreign import pause :: Socket -> Effect Unit

-- | Returns `true` if the `Socket` is not connected yet.
-- | Returns `false` otherwise.
foreign import pending :: Socket -> Effect Boolean

foreign import remoteAddressImpl :: Socket -> Effect (Nullable String)

-- | Attempts to return the address a `Socket` is connected to.
remoteAddress :: Socket -> Effect (Maybe String)
remoteAddress socket = ado
  address <- remoteAddressImpl socket
  in toMaybe address

foreign import remoteFamilyImpl :: Socket -> Effect (Nullable String)

-- | Attempts to return the IP family a `Socket` is connected to,
-- | either `"IPv4"` or `"IPv6"`.
remoteFamily :: Socket -> Effect (Maybe String)
remoteFamily socket = ado
  family <- remoteFamilyImpl socket
  in toMaybe family

foreign import remotePortImpl :: Socket -> Effect (Nullable Int)

-- | Attempts to return the port a `Socket` is connected to.
remotePort :: Socket -> Effect (Maybe Int)
remotePort socket = ado
  port <- remotePortImpl socket
  in toMaybe port

-- | Resumes emitting `'data'` events.
foreign import resume :: Socket -> Effect Unit

-- | Allows half open TCP connections.
-- | Defaults to `false`.
serverAllowHalfOpen :: Option ServerOptions Boolean
serverAllowHalfOpen = opt "allowHalfOpen"

-- | When `true`, pauses the `Socket` on incomming connections.
-- | Defaults to `false`.
serverPauseOnConnect :: Option ServerOptions Boolean
serverPauseOnConnect = opt "pauseOnConnect"

-- | Sets the `Encoding` for the data read on the `Socket`.
foreign import setEncoding :: Socket -> Encoding -> Effect Unit

-- | Sets keep-alive behavior.
-- | When `true`, it enables the behavior.
-- | When `false`, it disables the behavior.
-- | The `Int` is the initial delay in milliseconds before the first probe is
-- | sent to an idle `Socket`.
foreign import setKeepAlive :: Socket -> Boolean -> Int -> Effect Unit

-- | When `true`, disables the Nagle algorithm and sends data immedately.
-- | When `false`, enables the Nagle algorithm and buffers data before sending.
foreign import setNoDelay :: Socket -> Boolean -> Effect Unit

-- | When `0`, disables the existing timeout.
-- | Otherwise, sets the `Socket` to timeout after the given milliseconds.
-- | Adds the callback as a listener for the `'timeout'` event.
foreign import setTimeout :: Socket -> Int -> Effect Unit -> Effect Unit

-- | Allows half open TCP connections.
-- | Defaults to `false`.
socketAllowHalfOpen :: Option SocketOptions Boolean
socketAllowHalfOpen = opt "allowHalfOpen"

-- | Creates a `Socket` around the given `FileDescriptor`.
-- | If not specified, creates a new `Socket`.
socketFd :: Option SocketOptions FileDescriptor
socketFd = opt "fd"

-- | The host to configure TCP `Socket`s.
-- |
-- | Determines the host the `Socket` will attempt to connect to.
-- | Defaults to `localhost`.
socketHost :: Option SocketOptions String
socketHost = opt "host"

-- | The path to configure ICP `Socket`s.
-- |
-- | Determines the ICP endpoint the `Socket` will attempt to connect to.
socketPath :: Option SocketOptions String
socketPath = opt "path"

-- | The port to configure TCP `Socket`s.
-- |
-- | Determines the TCP endpoint the `Socket` will attempt to connect to.
socketPort :: Option SocketOptions Int
socketPort = opt "port"

-- | Allows reads if a `FileDescriptor` is also set.
-- | Defaults to `false`.
socketReadable :: Option SocketOptions Boolean
socketReadable = opt "readable"

-- | Passed to `setTimeout` when the `Socket` is created but before it starts
-- | the connection.
socketTimeout :: Option SocketOptions Int
socketTimeout = opt "timeout"

-- | Allows writes if a `FileDescriptor` is also set.
-- | Defaults to `false`.
socketWritable :: Option SocketOptions Boolean
socketWritable = opt "writable"

-- | Sends data on the `Socket` and invokes the callback after the data is
-- | finally written.
-- | Returns `true` if the data was flushed successfully.
-- | Returns `false` if the data was queued.
-- | Emits a `'drain'` event after the buffer is free.
foreign import write :: Socket -> Buffer -> Effect Unit -> Effect Boolean

-- | Sends data on the `Socket` and invokes the callback after the data is
-- | finally written.
-- | Returns `true` if the data was flushed successfully.
-- | Returns `false` if the data was queued.
-- | Emits a `'drain'` event after the buffer is free.
foreign import writeString :: Socket -> String -> Encoding -> Effect Unit -> Effect Boolean
