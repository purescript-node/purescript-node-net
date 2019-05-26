module Node.Net
  ( isIP
  , isIPv4
  , isIPv6
  ) where

-- | Returns `4` if the `String` is a valid IPv4 address, `6` if the `String`
-- | is a valid IPv6 address, and `0` otherwise.
foreign import isIP :: String -> Int

-- | Returns `true` if the `String` is a valid IPv4 address,
-- | and `false` otherwise.
foreign import isIPv4 :: String -> Boolean

-- | Returns `true` if the `String` is a valid IPv4 address,
-- | and `false` otherwise.
foreign import isIPv6 :: String -> Boolean
