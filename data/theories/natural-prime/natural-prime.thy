name: natural-prime
version: 1.0
description: Prime natural numbers
author: Joe Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: natural
requires: natural-divides
show: "Data.Bool"
show: "Number.Natural"

def {
  package: natural-prime-def-1.0
}

thm {
  import: def
  package: natural-prime-thm-1.1
}

main {
  import: def
  import: thm
}
