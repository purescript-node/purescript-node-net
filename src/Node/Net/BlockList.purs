module Node.Net.BlockList
  ( addAddressAddr
  , addAddressStr
  , addRangeStrStr
  , addRangeStrAddr
  , addRangeAddrStr
  , addRangeAddrAddr
  , addSubnetStr
  , addSubnetAddr
  , checkStr
  , checkAddr
  , rules
  ) where

import Prelude

import Effect (Effect)
import Effect.Uncurried (EffectFn1, EffectFn3, EffectFn4, runEffectFn1, runEffectFn3, runEffectFn4)
import Node.Net.Types (BlockList, IpFamily, SocketAddress, toNodeIpFamily)

foreign import addAddressImpl :: forall a. EffectFn3 (BlockList) a (String) (Unit)

addAddressAddr :: forall ipFamily. BlockList -> SocketAddress ipFamily -> IpFamily -> Effect Unit
addAddressAddr bl a ty = runEffectFn3 addAddressImpl bl a (toNodeIpFamily ty)

addAddressStr :: BlockList -> String -> IpFamily -> Effect Unit
addAddressStr bl a ty = runEffectFn3 addAddressImpl bl a (toNodeIpFamily ty)

foreign import addRangeImpl :: forall a b. EffectFn4 (BlockList) a b (IpFamily) (Unit)

addRangeStrStr :: BlockList -> String -> String -> IpFamily -> Effect Unit
addRangeStrStr bl start end ty = runEffectFn4 addRangeImpl bl start end ty

addRangeStrAddr :: forall ipFamily. BlockList -> String -> SocketAddress ipFamily -> IpFamily -> Effect Unit
addRangeStrAddr bl start end ty = runEffectFn4 addRangeImpl bl start end ty

addRangeAddrStr :: forall ipFamily. BlockList -> String -> SocketAddress ipFamily -> IpFamily -> Effect Unit
addRangeAddrStr bl start end ty = runEffectFn4 addRangeImpl bl start end ty

addRangeAddrAddr :: forall ipFamilyStart ipFamilyEnd. BlockList -> SocketAddress ipFamilyStart -> SocketAddress ipFamilyEnd -> IpFamily -> Effect Unit
addRangeAddrAddr bl start end ty = runEffectFn4 addRangeImpl bl start end ty

foreign import addSubnetImpl :: forall a. EffectFn4 (BlockList) a (Int) (IpFamily) (Unit)

addSubnetStr :: BlockList -> String -> Int -> IpFamily -> Effect Unit
addSubnetStr bl net prefix ty = runEffectFn4 addSubnetImpl bl net prefix ty

addSubnetAddr :: forall ipFamily. BlockList -> SocketAddress ipFamily -> Int -> IpFamily -> Effect Unit
addSubnetAddr bl net prefix ty = runEffectFn4 addSubnetImpl bl net prefix ty

foreign import checkImpl :: forall a. EffectFn3 (BlockList) a (IpFamily) (Boolean)

checkStr :: BlockList -> String -> IpFamily -> Effect Boolean
checkStr bl addresss ty = runEffectFn3 checkImpl bl addresss ty

checkAddr :: forall ipFamily. BlockList -> SocketAddress ipFamily -> IpFamily -> Effect Boolean
checkAddr bl addresss ty = runEffectFn3 checkImpl bl addresss ty

rules :: BlockList -> Effect (Array String)
rules bl = runEffectFn1 rulesImpl bl

foreign import rulesImpl :: EffectFn1 (BlockList) ((Array String))
