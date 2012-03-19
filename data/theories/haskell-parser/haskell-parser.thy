name: haskell-parser
version: 1.64
description: Simple stream parsers
author: Joe Hurd <joe@gilith.com>
license: MIT
requires: base
requires: parser
requires: haskell
show: "Data.Bool"
show: "Data.List"
show: "Data.Option"
show: "Data.Pair"
show: "Haskell.Parser"
show: "Number.Natural"

def {
  package: haskell-parser-def-1.18
}

thm {
  import: def
  package: haskell-parser-thm-1.14
}

src {
  import: def
  import: thm
  package: haskell-parser-src-1.37
}

test {
  import: def
  import: thm
  package: haskell-parser-test-1.9
}

main {
  import: def
  import: thm
  import: src
  import: test
}
