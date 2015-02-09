{- |
module: $Header$
description: Prime natural numbers
license: MIT

maintainer: Joe Leslie-Hurd <joe@gilith.com>
stability: provisional
portability: portable
-}

module OpenTheory.Prime
where

import qualified OpenTheory.Prime.Sieve as Sieve
import qualified OpenTheory.Primitive.Natural as Natural
import qualified OpenTheory.Stream as Stream

all :: [Natural.Natural]
all = Stream.unfold Sieve.next Sieve.initial
