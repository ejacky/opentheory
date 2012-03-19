name: natural-factorial
version: 1.18
description: Natural number factorial
author: Joe Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: natural-def
requires: natural-thm
requires: natural-numeral
requires: natural-order
requires: natural-add
requires: natural-mult
show: "Data.Bool"
show: "Number.Natural"

def {
  package: natural-factorial-def-1.17
}

thm {
  import: def
  package: natural-factorial-thm-1.17
}

main {
  import: def
  import: thm
}
