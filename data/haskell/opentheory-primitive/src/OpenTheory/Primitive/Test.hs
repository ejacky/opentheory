{- |
module: $Header$
description: OpenTheory QuickCheck interface
license: MIT

maintainer: Joe Leslie-Hurd <joe@gilith.com>
stability: provisional
portability: portable
-}
module OpenTheory.Primitive.Test
  ( assert,
    check )
where

import qualified Test.QuickCheck as QuickCheck

assert :: String -> Bool -> IO ()
assert desc prop =
    do putStr desc
       if prop
         then putStrLn "+++ OK"
         else
           do putStr "**"
              putStrLn "* Failed!"
              error "Assertion failed"

check :: QuickCheck.Testable prop => String -> prop -> IO ()
check desc prop =
    do putStr desc
       res <- QuickCheck.quickCheckWithResult args prop
       case res of
         QuickCheck.Failure {} -> error "Proposition failed"
         _ -> return ()
  where
    args = QuickCheck.stdArgs {QuickCheck.maxSuccess = 100}
