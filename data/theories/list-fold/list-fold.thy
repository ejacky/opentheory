name: list-fold
version: 1.5
description: List fold operations
author: Joe Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: function
requires: natural
requires: list-def
requires: list-length
requires: list-append
requires: list-reverse
show: "Data.Bool"
show: "Data.List"
show: "Function"
show: "Number.Natural"

def {
  package: list-fold-def-1.5
}

thm {
  import: def
  package: list-fold-thm-1.6
}

main {
  import: def
  import: thm
}