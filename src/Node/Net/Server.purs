module Node.Net.Server
  ( Address
  , ListenOptions
  , Server
  , ServerOptions
  , address
  , close
  , createServer
  , getConnections
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
  , onClose
  , onConnection
  , onError
  , onListening
  , serverAllowHalfOpen
  , serverPauseOnConnect
  ) where

import Prelude

import Control.Alt ((<|>))
import Control.Monad.Except (runExcept)
import Data.Either (Either(..), either)
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable, toMaybe)
import Data.Options (Option, Options, opt, options, (:=))
import Effect (Effect)
import Effect.Exception (Error)
import Effect.Uncurried (EffectFn1, EffectFn2, EffectFn3, mkEffectFn1, mkEffectFn2, runEffectFn1, runEffectFn2, runEffectFn3)
import Foreign (F, Foreign, readInt, readString)
import Foreign.Index (readProp)
import Node.Net.Socket (Socket)

type Address
  = { address :: String
    , family :: String
    , port :: Int
    }

-- | Options to configure the listening side of a `Server`.
-- | These options decide whether the `Server` is ICP or TCP.
-- |
-- | One of `path` or `port` must be set.
-- | Setting `path` will make the `Server` ICP.
-- | Setting `port` will make the `Server` TCP.
data ListenOptions

-- | An ICP or TCP server.
foreign import data Server :: Type

-- | Options to configure the basics of a `Server`.
data ServerOptions

foreign import addressImpl :: EffectFn1 Server (Nullable Foreign)

-- | Attempts to return the bound address of a `Server`.
-- |
-- | If the `Server` is not listening, `Nothing` is returned.
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

foreign import closeImpl :: EffectFn2 Server (EffectFn1 (Nullable Error) Unit) Unit

-- | Closes the `Server` and invokes the callback after the `'close'` event
-- | is emitted.
-- | An `Error` is passed to the callback if the `Server` was not open.
close :: Server -> (Maybe Error -> Effect Unit) -> Effect Unit
close server callback =
  runEffectFn2 closeImpl server (mkEffectFn1 \err -> callback $ toMaybe err)

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

foreign import getConnectionsImpl :: EffectFn2 Server (EffectFn2 (Nullable Error) (Nullable Int) Unit) Unit

-- | Returns the number of concurrent connections to the `Server`.
getConnections :: Server -> (Either Error Int -> Effect Unit) -> Effect Unit
getConnections server callback =
  runEffectFn2 getConnectionsImpl server $ mkEffectFn2 \err' count' ->
    case toMaybe err', toMaybe count' of
      Just err, _ -> callback (Left err)
      _, Just count -> callback (Right count)
      _, _ -> mempty

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

-- | Attaches the callback as a listener to the `'close'` event.
-- |
-- | `'close'` is emitted when a close occurs.
-- | Will not be emitted until all connections have ended.
onClose :: Server -> Effect Unit -> Effect Unit
onClose server callback = runEffectFn3 onImpl "close" server callback

-- | Attaches the callback as a listener to the `'connection'` event.
-- |
-- | `'connection'` is emitted when a new connection is made.
onConnection :: Server -> (Socket -> Effect Unit) -> Effect Unit
onConnection server callback =
  runEffectFn3
    onImpl
    "connection"
    server
    (mkEffectFn1 \socket -> callback socket)

-- | Attaches the callback as a listener to the `'error'` event.
-- |
-- | `'error'` is emitted when an error occurs.
onError :: Server -> (Error -> Effect Unit) -> Effect Unit
onError server callback =
  runEffectFn3 onImpl "error" server (mkEffectFn1 \error -> callback error)

-- | Attaches the callback as a listener to the `'listening'` event.
-- |
-- | `'listening'` is emitted when the `Server` has been bound.
onListening :: Server -> Effect Unit -> Effect Unit
onListening server callback = runEffectFn3 onImpl "listening" server callback

foreign import onImpl :: forall f. EffectFn3 String Server (f Unit) Unit

-- | Allows half open TCP connections.
-- | Defaults to `false`.
serverAllowHalfOpen :: Option ServerOptions Boolean
serverAllowHalfOpen = opt "allowHalfOpen"

-- | When `true`, pauses the `Socket` on incomming connections.
-- | Defaults to `false`.
serverPauseOnConnect :: Option ServerOptions Boolean
serverPauseOnConnect = opt "pauseOnConnect"
