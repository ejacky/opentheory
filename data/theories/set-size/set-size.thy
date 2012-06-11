name: set-size
version: 1.40
description: Finite set cardinality
author: Joe Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: natural
requires: pair
requires: set-def
requires: set-finite
requires: set-fold
requires: set-thm
show: "Data.Bool"
show: "Data.Pair"
show: "Number.Natural"
show: "Set"

def {
  package: set-size-def-1.20
}

thm {
  import: def
  package: set-size-thm-1.45
}

main {
  import: def
  import: thm
}
