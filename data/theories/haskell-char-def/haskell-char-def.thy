name: haskell-char-def
version: 1.15
description: Definition of Unicode characters
author: Joe Hurd <joe@gilith.com>
license: MIT
provenance: HOL Light theory extracted on 2012-08-10
requires: base
requires: byte
requires: char
requires: haskell-parser
requires: parser
requires: probability
requires: word16
show: "Data.Bool"
show: "Data.Byte"
show: "Data.Char"
show: "Data.Option"
show: "Data.Pair"
show: "Data.Word16"
show: "Function"
show: "Haskell.Data.Unicode" as "H"
show: "Haskell.Parser" as "H"
show: "Parser"
show: "Probability.Random"

main {
  article: "haskell-char-def.art"
}