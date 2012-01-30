name: list-nth
version: 1.32
description: The list nth function
author: Joe Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: natural
requires: set
requires: list-def
requires: list-thm
requires: list-dest
requires: list-length
requires: list-set
requires: list-append
requires: list-map
requires: list-quant
requires: list-last
show: "Data.Bool"
show: "Data.List"
show: "Number.Natural"
show: "Set"

def {
  package: list-nth-def-1.29
}

thm {
  import: def
  package: list-nth-thm-1.34
}

main {
  import: def
  import: thm
}
