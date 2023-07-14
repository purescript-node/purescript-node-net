module Node.Net.Server
  ( toEventEmitter
  , createTcpServer
  , createTcpServer'
  , createIpcServer
  , createIpcServer'
  , closeH
  , connectionH
  , errorH
  , listeningH
  , dropHandleTcp
  , dropHandleIpc
  , addressTcp
  , addressIpc
  , close
  , getConnections
  , listenTcp
  , listenIpc
  , listening
  , maxConnections
  , ref
  , unref
  ) where

import Prelude

import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import Effect (Effect)
import Effect.Exception (Error)
import Effect.Uncurried (EffectFn1, EffectFn2, mkEffectFn1, mkEffectFn2, runEffectFn1, runEffectFn2)
import Node.EventEmitter (EventEmitter, EventHandle(..))
import Node.EventEmitter.UtilTypes (EventHandle1, EventHandle0)
import Node.Net.Types (IPC, IpFamily, ListenIpcOptions, ListenTcpOptions, NewServerOptions, Server, Socket, TCP, unsafeFromNodeIpFamily)
import Prim.Row as Row
import Unsafe.Coerce (unsafeCoerce)

toEventEmitter :: forall connectionType. Server connectionType -> EventEmitter
toEventEmitter = unsafeCoerce

createTcpServer :: Effect (Server TCP)
createTcpServer = newServerImpl

createIpcServer :: Effect (Server IPC)
createIpcServer = newServerImpl

foreign import newServerImpl :: forall connectionType. Effect (Server connectionType)

createTcpServer'
  :: forall r trash
   . Row.Union r trash (NewServerOptions ())
  => { | r }
  -> Effect (Server TCP)
createTcpServer' o = runEffectFn1 newServerOptionsImpl o

createIpcServer'
  :: forall r trash
   . Row.Union r trash (NewServerOptions ())
  => { | r }
  -> Effect (Server IPC)
createIpcServer' o = runEffectFn1 newServerOptionsImpl o

foreign import newServerOptionsImpl :: forall r connectionType. EffectFn1 ({ | r }) (Server connectionType)

closeH :: forall connectionType. EventHandle0 (Server connectionType)
closeH = EventHandle "close" identity

connectionH :: forall connectionType. EventHandle1 (Server connectionType) (Socket connectionType)
connectionH = EventHandle "connection" mkEffectFn1

errorH :: forall connectionType. EventHandle1 (Server connectionType) Error
errorH = EventHandle "error" mkEffectFn1

listeningH :: forall connectionType. EventHandle0 (Server connectionType)
listeningH = EventHandle "listening" identity

dropHandleTcp
  :: EventHandle (Server TCP)
       ( { localAddress :: String
         , localPort :: Int
         , localFamily :: IpFamily
         , remoteAddress :: String
         , remotePort :: Int
         , remoteFamily :: IpFamily
         }
         -> Effect Unit
       )
       ( EffectFn1
           { localAddress :: String
           , localPort :: Int
           , localFamily :: String
           , remoteAddress :: String
           , remotePort :: Int
           , remoteFamily :: String
           }
           Unit
       )
dropHandleTcp = EventHandle "drop" \cb -> mkEffectFn1 \r ->
  cb
    { localAddress: r.localAddress
    , localPort: r.localPort
    , localFamily: unsafeFromNodeIpFamily r.localFamily
    , remoteAddress: r.remoteAddress
    , remotePort: r.remotePort
    , remoteFamily: unsafeFromNodeIpFamily r.remoteFamily
    }

dropHandleIpc :: EventHandle0 (Server IPC)
dropHandleIpc = EventHandle "drop" identity

addressTcp :: Server TCP -> Effect (Maybe { port :: Int, family :: IpFamily, address :: String })
addressTcp s = (runEffectFn1 addressTcpImpl s) <#>
  ( \o ->
      (toMaybe o) <#> \r ->
        { port: r.port
        , family: unsafeFromNodeIpFamily r.family
        , address: r.address
        }
  )

foreign import addressTcpImpl :: EffectFn1 (Server TCP) (Nullable { port :: Int, family :: String, address :: String })

addressIpc :: Server IPC -> Effect (Maybe String)
addressIpc s = map toMaybe $ runEffectFn1 addressIpcImpl s

foreign import addressIpcImpl :: EffectFn1 (Server IPC) (Nullable String)

close :: forall connectionType. Server connectionType -> Effect Unit
close s = runEffectFn1 closeImpl s

foreign import closeImpl :: forall connectionType. EffectFn1 (Server connectionType) (Unit)

getConnections :: forall connectionType. Server connectionType -> (Error -> Int -> Effect Unit) -> Effect Unit
getConnections s cb = runEffectFn2 getConnectionsImpl s $ mkEffectFn2 cb

foreign import getConnectionsImpl :: forall connectionType. EffectFn2 (Server connectionType) (EffectFn2 Error Int Unit) (Unit)

listenTcp
  :: forall r trash
   . Row.Union r trash (ListenTcpOptions ())
  => Server TCP
  -> { | r }
  -> Effect Unit
listenTcp s o = runEffectFn2 listenImpl s o

listenIpc
  :: forall r trash
   . Row.Union r trash (ListenIpcOptions ())
  => (Server IPC)
  -> { | r }
  -> Effect Unit
listenIpc s o = runEffectFn2 listenImpl s o

foreign import listenImpl :: forall r connectionType. EffectFn2 (Server connectionType) ({ | r }) (Unit)

listening :: forall connectionType. Server connectionType -> Effect Boolean
listening s = runEffectFn1 listeningImpl s

foreign import listeningImpl :: forall connectionType. EffectFn1 (Server connectionType) (Boolean)

maxConnections :: forall connectionType. Server connectionType -> Effect Int
maxConnections s = runEffectFn1 maxConnectionsImpl s

foreign import maxConnectionsImpl :: forall connectionType. EffectFn1 (Server connectionType) (Int)

ref :: forall connectionType. Server connectionType -> Effect Unit
ref s = runEffectFn1 refImpl s

foreign import refImpl :: forall connectionType. EffectFn1 (Server connectionType) (Unit)

unref :: forall connectionType. Server connectionType -> Effect Unit
unref s = runEffectFn1 unrefImpl s

foreign import unrefImpl :: forall connectionType. EffectFn1 (Server connectionType) (Unit)

