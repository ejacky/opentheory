name: list-set
version: 1.49
description: List to set conversions
author: Joe Leslie-Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: list-def
requires: list-dest
requires: list-length
requires: natural
requires: set
show: "Data.Bool"
show: "Data.List"
show: "Number.Natural"
show: "Set"

def {
  package: list-set-def-1.48
}

thm {
  import: def
  package: list-set-thm-1.47
}

main {
  import: def
  import: thm
}
