name: haskell-char
version: 1.31
description: Unicode characters
author: Joe Hurd <joe@gilith.com>
license: MIT
haskell-category: Text
requires: base
requires: char
requires: haskell
requires: haskell-parser
requires: parser
show: "Data.Bool"
show: "Data.Byte"
show: "Data.Char"
show: "Data.List"
show: "Data.Option"
show: "Data.Pair"
show: "Data.Word16"
show: "Function"
show: "Haskell.Data.Byte" as "H"
show: "Haskell.Data.List" as "H"
show: "Haskell.Data.Option" as "H"
show: "Haskell.Data.Unicode" as "H"
show: "Haskell.Data.Word16" as "H"
show: "Haskell.Number.Natural" as "H"
show: "Haskell.Parser" as "H"
show: "Number.Natural"
show: "Parser"
show: "Probability.Random"

def {
  package: haskell-char-def-1.15
}

src {
  import: def
  package: haskell-char-src-1.29
}

test {
  import: def
  package: haskell-char-test-1.16
}

main {
  import: def
  import: src
  import: test
}