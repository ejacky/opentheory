name: monoid
version: 1.6
description: Parametric theory of monoids
author: Joe Leslie-Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: list
requires: monoid-witness
requires: natural
requires: natural-bits
show: "Algebra.Monoid"
show: "Data.Bool"
show: "Data.List"
show: "Number.Natural"

thm {
  package: monoid-thm-1.2
}

mult {
  import: thm
  package: monoid-mult-1.6
}

main {
  import: thm
  import: mult
}
