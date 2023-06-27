module Node.Net.Socket
  ( newTcp
  , newIpc
  , toDuplex
  , toEventEmitter
  , closeH
  , connectH
  , lookupH
  , readyH
  , timeoutH
  , address
  , bytesRead
  , bytesWritten
  , createConnectionTCP
  , createConnectionIpc
  , connectTcp
  , connectIpc
  , connecting
  , destroySoon
  , localAddress
  , localPort
  , localFamily
  , pending
  , ref
  , remoteAddress
  , remotePort
  , remoteFamily
  , resetAndDestroy
  , setKeepAlive
  , setKeepAliveBoolean
  , setKeepAliveInitialDelay
  , setKeepAliveAll
  , setNoDelay
  , setNoDelay'
  , setTimeout
  , clearTimeout
  , timeout
  , unref
  , readyState
  ) where

import Prelude

import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import Data.Time.Duration (Milliseconds(..))
import Effect (Effect)
import Effect.Exception (Error)
import Effect.Uncurried (EffectFn1, EffectFn2, EffectFn3, EffectFn4, mkEffectFn1, mkEffectFn4, runEffectFn1, runEffectFn2, runEffectFn3)
import Node.EventEmitter (EventEmitter, EventHandle(..))
import Node.EventEmitter.UtilTypes (EventHandle0, EventHandle1)
import Node.Net.Types (ConnectIpcOptions, ConnectTcpOptions, IPC, IpFamily, NewSocketOptions, Socket, SocketReadyState(..), TCP, unsafeFromNodeIpFamily)
import Node.Stream (Duplex)
import Partial.Unsafe (unsafeCrashWith)
import Prim.Row as Row
import Unsafe.Coerce (unsafeCoerce)

foreign import newImpl :: forall r a. EffectFn1 ({ | r }) (Socket a)

newTcp
  :: forall r trash
   . Row.Union r trash (NewSocketOptions ())
  => { | r }
  -> Effect (Socket TCP)
newTcp o = runEffectFn1 newImpl o

newIpc
  :: forall r trash
   . Row.Union r trash (NewSocketOptions ())
  => { | r }
  -> Effect (Socket IPC)
newIpc o = runEffectFn1 newImpl o

toDuplex :: forall connectionType. Socket connectionType -> Duplex
toDuplex = unsafeCoerce

toEventEmitter :: forall connectionType. Socket connectionType -> EventEmitter
toEventEmitter = unsafeCoerce

closeH :: forall connectionType. EventHandle1 (Socket connectionType) Boolean
closeH = EventHandle "close" mkEffectFn1

connectH :: forall connectionType. EventHandle0 (Socket connectionType)
connectH = EventHandle "connect" identity

lookupH :: forall connectionType. EventHandle (Socket connectionType) (Maybe Error -> String -> Maybe Int -> String -> Effect Unit) (EffectFn4 (Nullable Error) String (Nullable Int) String Unit)
lookupH = EventHandle "lookup" \cb -> mkEffectFn4 \a b c d -> cb (toMaybe a) b (toMaybe c) d

readyH :: forall connectionType. EventHandle0 (Socket connectionType)
readyH = EventHandle "ready" identity

timeoutH :: forall connectionType. EventHandle0 (Socket connectionType)
timeoutH = EventHandle "timeout" identity

address :: forall connectionType. Socket connectionType -> Effect { port :: Int, family :: IpFamily, address :: String }
address s = do
  (runEffectFn1 addressImpl s) <#> \r ->
    { port: r.port
    , family: unsafeFromNodeIpFamily r.family
    , address: r.address
    }

foreign import addressImpl :: forall connectionType. EffectFn1 (Socket connectionType) ({ port :: Int, family :: String, address :: String })

bytesRead :: forall connectionType. Socket connectionType -> Effect Int
bytesRead s = runEffectFn1 bytesReadImpl s

foreign import bytesReadImpl :: forall connectionType. EffectFn1 (Socket connectionType) (Int)

bytesWritten :: forall connectionType. Socket connectionType -> Effect Int
bytesWritten s = runEffectFn1 bytesWrittenImpl s

foreign import bytesWrittenImpl :: forall connectionType. EffectFn1 (Socket connectionType) (Int)

-- | At least `port` must be specified
createConnectionTCP
  :: forall r trash
   . Row.Union r trash (NewSocketOptions (ConnectTcpOptions ()))
  => { | r }
  -> Effect (Socket TCP)
createConnectionTCP o = runEffectFn1 createConnectionImpl o

-- | At least `path` must be specified
createConnectionIpc
  :: forall r trash
   . Row.Union r trash (NewSocketOptions (ConnectIpcOptions ()))
  => { | r }
  -> Effect (Socket IPC)
createConnectionIpc o = runEffectFn1 createConnectionImpl o

foreign import createConnectionImpl :: forall r connectionType. EffectFn1 ({ | r }) (Socket connectionType)

-- | See `ConnectTcpOptions` for options
connectTcp
  :: forall r trash
   . Row.Union r trash (ConnectTcpOptions ())
  => Socket TCP
  -> { | r }
  -> Effect (Socket TCP)
connectTcp = runEffectFn2 connectTcpImpl

foreign import connectTcpImpl :: forall r. EffectFn2 (Socket TCP) ({ | r }) (Socket TCP)

connectIpc
  :: Socket IPC
  -> String
  -> Effect (Socket IPC)
connectIpc socket path = runEffectFn2 connectIpcImpl socket path

foreign import connectIpcImpl :: EffectFn2 (Socket IPC) String (Socket IPC)

connecting :: forall connectionType. Socket connectionType -> Effect Boolean
connecting s = runEffectFn1 connectingImpl s

foreign import connectingImpl :: forall connectionType. EffectFn1 (Socket connectionType) (Boolean)

destroySoon :: forall connectionType. Socket connectionType -> Effect Unit
destroySoon s = runEffectFn1 destroySoonImpl s

foreign import destroySoonImpl :: forall connectionType. EffectFn1 (Socket connectionType) (Unit)

localAddress :: forall connectionType. Socket connectionType -> Effect String
localAddress s = runEffectFn1 localAddressImpl s

foreign import localAddressImpl :: forall connectionType. EffectFn1 (Socket connectionType) (String)

localPort :: forall connectionType. Socket connectionType -> Effect Int
localPort s = runEffectFn1 localPortImpl s

foreign import localPortImpl :: forall connectionType. EffectFn1 (Socket connectionType) (Int)

localFamily :: forall connectionType. Socket connectionType -> Effect IpFamily
localFamily s = map unsafeFromNodeIpFamily $ runEffectFn1 localFamilyImpl s

foreign import localFamilyImpl :: forall connectionType. EffectFn1 (Socket connectionType) (String)

pending :: forall connectionType. Socket connectionType -> Effect Boolean
pending s = runEffectFn1 pendingImpl s

foreign import pendingImpl :: forall connectionType. EffectFn1 (Socket connectionType) (Boolean)

ref :: forall connectionType. Socket connectionType -> Effect Unit
ref s = runEffectFn1 refImpl s

foreign import refImpl :: forall connectionType. EffectFn1 (Socket connectionType) (Unit)

remoteAddress :: forall connectionType. Socket connectionType -> Effect String
remoteAddress s = runEffectFn1 remoteAddressImpl s

foreign import remoteAddressImpl :: forall connectionType. EffectFn1 (Socket connectionType) (String)

remotePort :: forall connectionType. Socket connectionType -> Effect Int
remotePort s = runEffectFn1 remotePortImpl s

foreign import remotePortImpl :: forall connectionType. EffectFn1 (Socket connectionType) (Int)

remoteFamily :: forall connectionType. Socket connectionType -> Effect IpFamily
remoteFamily s = map unsafeFromNodeIpFamily $ runEffectFn1 remoteFamilyImpl s

foreign import remoteFamilyImpl :: forall connectionType. EffectFn1 (Socket connectionType) (String)

resetAndDestroy :: Socket TCP -> Effect Unit
resetAndDestroy s = runEffectFn1 resetAndDestroyImpl s

foreign import resetAndDestroyImpl :: EffectFn1 (Socket TCP) (Unit)

setKeepAlive :: Socket TCP -> Effect Unit
setKeepAlive s = runEffectFn1 setKeepAliveImpl s

foreign import setKeepAliveImpl :: EffectFn1 (Socket TCP) (Unit)

setKeepAliveBoolean :: Socket TCP -> Boolean -> Effect Unit
setKeepAliveBoolean s b = runEffectFn2 setKeepAliveBooleanImpl s b

foreign import setKeepAliveBooleanImpl :: EffectFn2 (Socket TCP) (Boolean) (Unit)

setKeepAliveInitialDelay :: Socket TCP -> Int -> Effect Unit
setKeepAliveInitialDelay s delay = runEffectFn2 setKeepAliveInitialDelayImpl s delay

foreign import setKeepAliveInitialDelayImpl :: EffectFn2 (Socket TCP) (Int) (Unit)

setKeepAliveAll :: Socket TCP -> Boolean -> Int -> Effect Unit
setKeepAliveAll s b i = runEffectFn3 setKeepAliveAllImpl s b i

foreign import setKeepAliveAllImpl :: EffectFn3 (Socket TCP) (Boolean) (Int) (Unit)

setNoDelay :: Socket TCP -> Effect Unit
setNoDelay s = runEffectFn1 setNoDelayImpl s

foreign import setNoDelayImpl :: EffectFn1 (Socket TCP) (Unit)

setNoDelay' :: Socket TCP -> Boolean -> Effect Unit
setNoDelay' s b = runEffectFn2 setNoDelayBooleanImpl s b

foreign import setNoDelayBooleanImpl :: EffectFn2 (Socket TCP) (Boolean) (Unit)

setTimeout :: forall connectionType. Socket connectionType -> Milliseconds -> Effect Unit
setTimeout s msecs = runEffectFn2 setTimeoutImpl s msecs

foreign import setTimeoutImpl :: forall connectionType. EffectFn2 (Socket connectionType) (Milliseconds) (Unit)

clearTimeout :: forall connectionType. Socket connectionType -> Effect Unit
clearTimeout s = setTimeout s (Milliseconds 0.0)

timeout :: forall connectionType. Socket connectionType -> Effect (Maybe Milliseconds)
timeout s = map toMaybe $ runEffectFn1 timeoutImpl s

foreign import timeoutImpl :: forall connectionType. EffectFn1 (Socket connectionType) (Nullable Milliseconds)

unref :: forall connectionType. Socket connectionType -> Effect Unit
unref s = runEffectFn1 unrefImpl s

foreign import unrefImpl :: forall connectionType. EffectFn1 (Socket connectionType) (Unit)

readyState :: forall connectionType. Socket connectionType -> Effect SocketReadyState
readyState s = (runEffectFn1 readyStateImpl s) <#> case _ of
  "opening" -> Opening
  "open" -> Open
  "readOnly" -> ReadOnly
  "writeOnly" -> WriteOnly
  x -> unsafeCrashWith $ "Impossible. Unknown socket ready state: " <> show x

foreign import readyStateImpl :: forall connectionType. EffectFn1 (Socket connectionType) (String)
