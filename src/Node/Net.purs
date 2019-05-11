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
import Effect.Uncurried (EffectFn1, EffectFn2, EffectFn3, EffectFn4, mkEffectFn1, mkEffectFn2, mkEffectFn4, runEffectFn1, runEffectFn2, runEffectFn3, runEffectFn4)
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
    , family :: Maybe Int
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

foreign import addressImpl :: EffectFn1 Server (Nullable Foreign)

-- | Attempts to return the bound address of a `Server`.
-- |
-- | If the `Server` is not listening, no `Nothing` is returned.
-- | If the `Server` is ICP, it will return a `String`.
-- | If the `Server` is TCP, it will return an `Address`.
address :: Server -> Effect (Maybe (Either Address String))
address server = do
  x <- runEffectFn1 addressImpl server
  pure (toMaybe x >>= read)
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

foreign import bufferSizeImpl :: EffectFn1 Socket (Nullable Int)

-- | The number of characters buffered to be written on a `Socket`.
-- |
-- | N.B. The number of characters is not equal to the number of bytes.
bufferSize :: Socket -> Effect (Maybe Int)
bufferSize socket = do
  size <- runEffectFn1 bufferSizeImpl socket
  pure (toMaybe size)

foreign import bytesReadImpl :: EffectFn1 Socket Int

-- | The number of bytes recieved on the `Socket`.
bytesRead :: Socket -> Effect Int
bytesRead socket = runEffectFn1 bytesReadImpl socket

foreign import bytesWrittenImpl :: EffectFn1 Socket Int

-- | The number of bytes sent on the `Socket`.
bytesWritten :: Socket -> Effect Int
bytesWritten socket = runEffectFn1 bytesWrittenImpl socket

foreign import closeImpl :: EffectFn2 Server (EffectFn1 (Nullable Error) Unit) Unit

-- | Closes the `Server` and invokes the callback after the `'close'` event
-- | is emitted.
-- | An `Error` is passed to the callback if the `Server` was not open.
close :: Server -> (Maybe Error -> Effect Unit) -> Effect Unit
close server callback =
  runEffectFn2 closeImpl server (mkEffectFn1 \err -> callback $ toMaybe err)

foreign import connectImpl :: EffectFn3 Socket Foreign (Effect Unit) Unit

-- | Creates a custom ICP or TCP connection on the `Socket`.
-- | Normally, `createConnection` should be used to create the socket.
connect :: Socket -> Options ConnectOptions -> Effect Unit -> Effect Unit
connect socket opts callback =
  runEffectFn3 connectImpl socket (options opts) callback

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
connectICP socket path callback =
  runEffectFn3 connectImpl socket (options $ connectPath := path) callback

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
connectTCP socket port host callback =
  runEffectFn3
    connectImpl
    socket
    (options $ connectHost := host <> connectPort := port)
    callback

foreign import connectingImpl :: EffectFn1 Socket Boolean

-- | Returns `true` if `connect` was called, but the `'connect'` event hasn't
-- | been emitted yet.
-- | Returns `false` any other time.
connecting :: Socket -> Effect Boolean
connecting socket = runEffectFn1 connectingImpl socket

foreign import createConnectionImpl :: EffectFn2 Foreign (Effect Unit) Socket

-- | Creates an ICP or TCP `Socket`, initiates a connection,
-- | returns the `Socket`, adds the callback as a one-time listener for the
-- | `'connect'` event, and emits the `'connect'` event.
createConnection :: Options SocketOptions -> Effect Unit -> Effect Socket
createConnection opts callback =
  runEffectFn2 createConnectionImpl (options opts) callback

-- | Creates an ICP `Socket`, initiates a connection,
-- | returns the `Socket`, adds the callback as a one-time listener for the
-- | `'connect'` event, and emits the `'connect'` event.
createConnectionICP :: String -> Effect Unit -> Effect Socket
createConnectionICP path callback =
  runEffectFn2 createConnectionImpl (options $ socketPath := path) callback

-- | Creates a TCP `Socket`, initiates a connection,
-- | returns the `Socket`, adds the callback as a one-time listener for the
-- | `'connect'` event, and emits the `'connect'` event.
createConnectionTCP :: Int -> String -> Effect Unit -> Effect Socket
createConnectionTCP port host callback =
  runEffectFn2
    createConnectionImpl
    (options $ socketHost := host <> socketPort := port)
    callback

foreign import createServerImpl :: EffectFn2 Foreign (EffectFn1 Socket Unit) Server

-- | Creates an ICP or TCP `Server`, returns the `Server`,
-- | and adds the callback as a listenter for the `'connection'` event.
-- | the `Server` will be ICP or TCP depending on what it `listen`s to.
createServer :: Options ServerOptions -> (Socket -> Effect Unit) -> Effect Server
createServer opts callback =
  runEffectFn2
    createServerImpl
    (options opts)
    (mkEffectFn1 \socket -> callback socket)

foreign import destroyImpl :: EffectFn2 Socket (Nullable Error) Unit

-- | Ensure no more I/O activity happens on the socket.
-- |
-- | If an `Error` is provided, an `'error'` event is emitted.
destroy :: Socket -> Maybe Error -> Effect Unit
destroy socket err = runEffectFn2 destroyImpl socket (toNullable err)

foreign import destroyedImpl :: EffectFn1 Socket Boolean

-- | Returns `true` if the connection is destroyed and can no longer transfer
-- | data.
destroyed :: Socket -> Effect Boolean
destroyed socket = runEffectFn1 destroyedImpl socket

foreign import endImpl :: EffectFn3 Socket Buffer (Effect Unit) Unit

-- | Send a `FIN` packet to half-close the `Socket`.
-- | The server might still send more data.
-- | Invokes the callback after the `Socket` is finished.
end :: Socket -> Buffer -> Effect Unit -> Effect Unit
end socket buffer callback = runEffectFn3 endImpl socket buffer callback

foreign import endStringImpl :: EffectFn4 Socket String Encoding (Effect Unit) Unit

-- | Send a `FIN` packet to half-close the `Socket`.
-- | The server might still send more data.
-- | Invokes the callback after the `Socket` is finished.
endString :: Socket -> String -> Encoding -> Effect Unit -> Effect Unit
endString socket str encoding callback =
  runEffectFn4 endStringImpl socket str encoding callback

foreign import getConnectionsImpl :: EffectFn2 Server (EffectFn2 (Nullable Error) (Nullable Int) Unit) Unit

-- | Returns the number of concurrent connections to the `Server`.
getConnections :: Server -> (Either Error Int -> Effect Unit) -> Effect Unit
getConnections server callback =
  runEffectFn2 getConnectionsImpl server $ mkEffectFn2 \err' count' ->
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

foreign import listenImpl :: EffectFn3 Server Foreign (Effect Unit) Unit

-- | Starts the `Server` as an ICP or TCP `Server` listening for connections,
-- | adds the callback as a listener to the `'listening'` event, and emits the
-- | `'listening'` event.
listen :: Server -> Options ListenOptions -> Effect Unit -> Effect Unit
listen server opts callback =
  runEffectFn3 listenImpl server (options opts) callback

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
listenICP server path backlog callback =
  runEffectFn3
    listenImpl
    server
    (options $ listenBacklog := backlog <> listenPath := path)
    callback

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
listenTCP server port host backlog callback =
  runEffectFn3
    listenImpl
    server
    (options $ listenBacklog := backlog <> listenHost := host <> listenPort := port)
    callback

-- | Makes the ICP pipe writable for all users.
-- | Defaults to `false`.
listenWritableAll :: Option ListenOptions Boolean
listenWritableAll = opt "writableAll"

foreign import listeningImpl :: EffectFn1 Server Boolean

-- | Returns `true` if the `Server` is listening for connections, and `false`
-- | otherwise.
listening :: Server -> Effect Boolean
listening server = runEffectFn1 listeningImpl server

foreign import localAddressImpl :: EffectFn1 Socket (Nullable String)

-- | Attempts to return the address a client is connecting on.
-- | E.g. if a client connects from `192.168.1.1`,
-- | the result would be `Just "192.168.1.1"`.
localAddress :: Socket -> Effect (Maybe String)
localAddress socket = do
  address' <- runEffectFn1 localAddressImpl socket
  pure (toMaybe address')

foreign import localPortImpl :: EffectFn1 Socket (Nullable Int)

-- | Attempts to return the port a client is connecting on.
-- | E.g. if a client connects from `80`,
-- | the result would be `Just "80"`.
localPort :: Socket -> Effect (Maybe Int)
localPort socket = do
  port <- runEffectFn1 localPortImpl socket
  pure (toMaybe port)

foreign import onCloseServerImpl :: EffectFn2 Server (Effect Unit) Unit

-- | Attaches the callback as a listener to the `'close'` event.
-- |
-- | `'close'` is emitted when a close occurs.
-- | Will not be emitted until all connections have ended.
onCloseServer :: Server -> Effect Unit -> Effect Unit
onCloseServer server callback = runEffectFn2 onCloseServerImpl server callback

foreign import onCloseSocketImpl :: EffectFn2 Socket (EffectFn1 Boolean Unit) Unit

-- | Attaches the callback as a listener to the `'close'` event.
-- | The `Boolean` represents whether an error happened during transmission.
-- |
-- | `'close'` is emitted when an close occurs.
onCloseSocket :: Socket -> (Boolean -> Effect Unit) -> Effect Unit
onCloseSocket socket callback =
  runEffectFn2
    onCloseSocketImpl
    socket
    (mkEffectFn1 \hadError -> callback hadError)

foreign import onConnectImpl :: EffectFn2 Socket (Effect Unit) Unit

-- | Attaches the callback as a listener to the `'connect'` event.
-- |
-- | `'connect'` is emitted when a new connection is successfully establed.
onConnect :: Socket -> Effect Unit -> Effect Unit
onConnect socket callback = runEffectFn2 onConnectImpl socket callback

foreign import onConnectionImpl :: EffectFn2 Server (EffectFn1 Socket Unit) Unit

-- | Attaches the callback as a listener to the `'connection'` event.
-- |
-- | `'connection'` is emitted when a new connection is made.
onConnection :: Server -> (Socket -> Effect Unit) -> Effect Unit
onConnection server callback =
  runEffectFn2 onConnectionImpl server (mkEffectFn1 \socket -> callback socket)

foreign import onDataImpl :: EffectFn3 Socket (EffectFn1 Buffer Unit) (EffectFn1 String Unit) Unit

-- | Attaches the callback as a listener to the `'data'` event.
-- |
-- | `'data'` is emitted when a data is recieved.
-- | Data will be lost if there is no listener when `'data'` is emitted.
onData :: Socket -> (Either Buffer String -> Effect Unit) -> Effect Unit
onData socket callback =
  runEffectFn3
    onDataImpl
    socket
    (mkEffectFn1 \buffer -> callback $ Left buffer)
    (mkEffectFn1 \str -> callback $ Right str)

foreign import onDrainImpl :: EffectFn2 Socket (Effect Unit) Boolean

-- | Attaches the callback as a listener to the `'drain'` event.
-- |
-- | `'drain'` is emitted when the write buffer is empty.
onDrain :: Socket -> Effect Unit -> Effect Boolean
onDrain socket callback = runEffectFn2 onDrainImpl socket callback

foreign import onEndImpl :: EffectFn2 Socket (Effect Unit) Unit

-- | Attaches the callback as a listener to the `'end'` event.
-- |
-- | `'end'` is emitted when the other end of the `Socket` sends a `FIN` packet.
onEnd :: Socket -> Effect Unit -> Effect Unit
onEnd socket callback = runEffectFn2 onEndImpl socket callback

foreign import onErrorServerImpl :: EffectFn2 Server (EffectFn1 Error Unit) Unit

-- | Attaches the callback as a listener to the `'error'` event.
-- |
-- | `'error'` is emitted when an error occurs.
onErrorServer :: Server -> (Error -> Effect Unit) -> Effect Unit
onErrorServer server callback =
  runEffectFn2 onErrorServerImpl server (mkEffectFn1 \error -> callback error)

foreign import onErrorSocketImpl :: EffectFn2 Socket (EffectFn1 Error Unit) Unit

-- | Attaches the callback as a listener to the `'error'` event.
-- |
-- | `'error'` is emitted when an error occurs.
-- | `'close'` is emitted directly after this event.
onErrorSocket :: Socket -> (Error -> Effect Unit) -> Effect Unit
onErrorSocket socket callback =
  runEffectFn2 onErrorSocketImpl socket (mkEffectFn1 \error -> callback error)

foreign import onListeningImpl :: EffectFn2 Server (Effect Unit) Unit

-- | Attaches the callback as a listener to the `'listening'` event.
-- |
-- | `'listening'` is emitted when the `Server` has been bound.
onListening :: Server -> Effect Unit -> Effect Unit
onListening server callback = runEffectFn2 onListeningImpl server callback

foreign import onLookupImpl :: EffectFn2 Socket (EffectFn4 (Nullable Error) (Nullable String) (Nullable (Nullable Int)) (Nullable String) Unit) Unit

-- | Attaches the callback as a listener to the `'lookup'` event.
-- |
-- | `'lookup'` is emitted after resolving the hostname but before connecting.
onLookup :: Socket -> (Either Error Lookup -> Effect Unit) -> Effect Unit
onLookup socket callback =
  runEffectFn2 onLookupImpl socket $ mkEffectFn4 \err' address'' family' host' ->
    case toMaybe err', toMaybe address'', toMaybe family', toMaybe host' of
      Just err, _, _, _ -> callback (Left err)
      Nothing, Just address', Just family, Just host ->
        callback (Right { address: address', family: toMaybe family, host })
      _, _, _, _ -> mempty

foreign import onReadyImpl :: EffectFn2 Socket (Effect Unit) Unit

-- | Attaches the callback as a listener to the `'ready'` event.
-- |
-- | `'ready'` is emitted when the `Socket` is ready to be used.
onReady :: Socket -> Effect Unit -> Effect Unit
onReady socket callback = runEffectFn2 onReadyImpl socket callback

foreign import onTimeoutImpl :: EffectFn2 Socket (Effect Unit) Unit

-- | Attaches the callback as a listener to the `'timeout'` event.
-- |
-- | `'timeout'` is emitted if the `Socket` times out from inactivity.
-- | The `Socket` is still open and should be manually closed.
onTimeout :: Socket -> Effect Unit -> Effect Unit
onTimeout socket callback = runEffectFn2 onTimeoutImpl socket callback

foreign import pauseImpl :: EffectFn1 Socket Unit

-- | Pauses `'data'` events from being emitted.
pause :: Socket -> Effect Unit
pause socket = runEffectFn1 pauseImpl socket

foreign import pendingImpl :: EffectFn1 Socket Boolean

-- | Returns `true` if the `Socket` is not connected yet.
-- | Returns `false` otherwise.
pending :: Socket -> Effect Boolean
pending socket = runEffectFn1 pendingImpl socket

foreign import remoteAddressImpl :: EffectFn1 Socket (Nullable String)

-- | Attempts to return the address a `Socket` is connected to.
remoteAddress :: Socket -> Effect (Maybe String)
remoteAddress socket = do
  address' <- runEffectFn1 remoteAddressImpl socket
  pure (toMaybe address')

foreign import remoteFamilyImpl :: EffectFn1 Socket (Nullable String)

-- | Attempts to return the IP family a `Socket` is connected to,
-- | either `"IPv4"` or `"IPv6"`.
remoteFamily :: Socket -> Effect (Maybe String)
remoteFamily socket = do
  family <- runEffectFn1 remoteFamilyImpl socket
  pure (toMaybe family)

foreign import remotePortImpl :: EffectFn1 Socket (Nullable Int)

-- | Attempts to return the port a `Socket` is connected to.
remotePort :: Socket -> Effect (Maybe Int)
remotePort socket = do
  port <- runEffectFn1 remotePortImpl socket
  pure (toMaybe port)

foreign import resumeImpl :: EffectFn1 Socket Unit

-- | Resumes emitting `'data'` events.
resume :: Socket -> Effect Unit
resume socket = runEffectFn1 resumeImpl socket

-- | Allows half open TCP connections.
-- | Defaults to `false`.
serverAllowHalfOpen :: Option ServerOptions Boolean
serverAllowHalfOpen = opt "allowHalfOpen"

-- | When `true`, pauses the `Socket` on incomming connections.
-- | Defaults to `false`.
serverPauseOnConnect :: Option ServerOptions Boolean
serverPauseOnConnect = opt "pauseOnConnect"

foreign import setEncodingImpl :: EffectFn2 Socket Encoding Unit

-- | Sets the `Encoding` for the data read on the `Socket`.
setEncoding :: Socket -> Encoding -> Effect Unit
setEncoding socket encoding = runEffectFn2 setEncodingImpl socket encoding

foreign import setKeepAliveImpl :: EffectFn3 Socket Boolean Int Unit

-- | Sets keep-alive behavior.
-- | When `true`, it enables the behavior.
-- | When `false`, it disables the behavior.
-- | The `Int` is the initial delay in milliseconds before the first probe is
-- | sent to an idle `Socket`.
setKeepAlive :: Socket -> Boolean -> Int -> Effect Unit
setKeepAlive socket enable initialDelay =
  runEffectFn3 setKeepAliveImpl socket enable initialDelay

foreign import setNoDelayImpl :: EffectFn2 Socket Boolean Unit

-- | When `true`, disables the Nagle algorithm and sends data immedately.
-- | When `false`, enables the Nagle algorithm and buffers data before sending.
setNoDelay :: Socket -> Boolean -> Effect Unit
setNoDelay socket noDelay = runEffectFn2 setNoDelayImpl socket noDelay

foreign import setTimeoutImpl :: EffectFn3 Socket Int (Effect Unit) Unit

-- | When `0`, disables the existing timeout.
-- | Otherwise, sets the `Socket` to timeout after the given milliseconds.
-- | Adds the callback as a listener for the `'timeout'` event.
setTimeout :: Socket -> Int -> Effect Unit -> Effect Unit
setTimeout socket timeout callback =
  runEffectFn3 setTimeoutImpl socket timeout callback

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

foreign import writeImpl :: EffectFn3 Socket Buffer (Effect Unit) Boolean

-- | Sends data on the `Socket` and invokes the callback after the data is
-- | finally written.
-- | Returns `true` if the data was flushed successfully.
-- | Returns `false` if the data was queued.
-- | Emits a `'drain'` event after the buffer is free.
write :: Socket -> Buffer -> Effect Unit -> Effect Boolean
write socket buffer callback = runEffectFn3 writeImpl socket buffer callback

foreign import writeStringImpl :: EffectFn4 Socket String Encoding (Effect Unit) Boolean

-- | Sends data on the `Socket` and invokes the callback after the data is
-- | finally written.
-- | Returns `true` if the data was flushed successfully.
-- | Returns `false` if the data was queued.
-- | Emits a `'drain'` event after the buffer is free.
writeString :: Socket -> String -> Encoding -> Effect Unit -> Effect Boolean
writeString socket str encoding callback =
  runEffectFn4 writeStringImpl socket str encoding callback
