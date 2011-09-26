{- |
Module: $Header$
Description: Simple stream parsers
License: MIT

Maintainer: Joe Hurd <joe@gilith.com>
Stability: provisional
Portability: portable
-}
module OpenTheory.Parser
where

import qualified OpenTheory.Parser.Stream as Stream

newtype Parser a b =
  Parser { unParser :: a -> Stream.Stream a -> Maybe (b, Stream.Stream a) }

parse :: Parser a b -> Stream.Stream a -> Maybe (b, Stream.Stream a)
parse _ Stream.Error = Nothing
parse _ Stream.Eof = Nothing
parse p (Stream.Stream a s) = unParser p a s
