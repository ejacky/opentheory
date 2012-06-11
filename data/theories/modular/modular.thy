name: modular
version: 1.54
description: Parametric theory of modular arithmetic
author: Joe Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: modular-witness
requires: natural
requires: natural-divides
show: "Data.Bool"
show: "Number.Modular"
show: "Number.Natural"

def {
  package: modular-def-1.51
}

thm {
  import: def
  package: modular-thm-1.41
}

main {
  import: def
  import: thm
}
