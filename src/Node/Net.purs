module Node.Net
  ( isIP
  , isIP'
  , isIPv4
  , isIPv6
  ) where

import Data.Maybe (Maybe(..))
import Node.Net.Types (IpFamily(..))

isIP :: String -> Maybe IpFamily
isIP s = case isIP' s of
  4 -> Just IPv4
  6 -> Just IPv6
  _ -> Nothing

-- | Returns `4` if the `String` is a valid IPv4 address, `6` if the `String`
-- | is a valid IPv6 address, and `0` otherwise.
isIP' :: String -> Int
isIP' = isIPImpl

foreign import isIPImpl :: String -> Int

-- | Returns `true` if the `String` is a valid IPv4 address,
-- | and `false` otherwise.
foreign import isIPv4 :: String -> Boolean

-- | Returns `true` if the `String` is a valid IPv4 address,
-- | and `false` otherwise.
foreign import isIPv6 :: String -> Boolean
