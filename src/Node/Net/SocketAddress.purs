module Node.Net.SocketAddress
  ( Ipv4SocketAddressOptions
  , Ipv6SocketAddressOptions
  , newIpv4
  , newIpv6
  , address
  , family
  , flowLabel
  , port
  ) where

import Prelude

import Data.Maybe (Maybe)
import Data.Nullable (Nullable, toMaybe)
import Effect (Effect)
import Effect.Uncurried (EffectFn1, runEffectFn1)
import Node.Net.Types (IPv4, IPv6, IpFamily(..), SocketAddress, toNodeIpFamily, unsafeFromNodeIpFamily)

-- | `address` <string> The network address as either an IPv4 or IPv6 string. Default: '127.0.0.1' if family is 'ipv4'; '::' if family is 'ipv6'.
-- | `family` <string> One of either 'ipv4' or 'ipv6'. Default: 'ipv4'.
-- | `flowlabel` <number> An IPv6 flow-label used only if family is 'ipv6'.
-- | `port` <number> An IP port.
type Ipv4SocketAddressOptions =
  { address :: String
  , port :: Int
  }

type Ipv6SocketAddressOptions =
  { address :: String
  , flowLabel :: Int
  , port :: Int
  }

foreign import newImpl :: forall a b. EffectFn1 { | a } (SocketAddress b)

newIpv4 :: Ipv4SocketAddressOptions -> Effect (SocketAddress IPv4)
newIpv4 r =
  runEffectFn1 newImpl { address: r.address, family: toNodeIpFamily IPv4, port: r.port }

newIpv6 :: Ipv6SocketAddressOptions -> Effect (SocketAddress IPv6)
newIpv6 r =
  runEffectFn1 newImpl { address: r.address, family: toNodeIpFamily IPv6, flowLabel: r.flowLabel, port: r.port }

foreign import address :: forall ipFamily. SocketAddress ipFamily -> String

family :: forall ipFamily. SocketAddress ipFamily -> IpFamily
family sa = unsafeFromNodeIpFamily $ familyImpl sa

foreign import familyImpl :: forall ipFamily. SocketAddress ipFamily -> String

flowLabel :: SocketAddress IPv6 -> Maybe Int
flowLabel = toMaybe <<< flowLabelImpl

foreign import flowLabelImpl :: SocketAddress IPv6 -> Nullable Int

foreign import port :: forall ipFamily. SocketAddress ipFamily -> Int
