name: gfp-div
version: 1.23
description: GF(p) field division
author: Joe Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: pair
requires: natural
requires: relation
requires: natural-divides
requires: natural-gcd
requires: natural-prime
requires: gfp-witness
requires: gfp-def
requires: gfp-thm
show: "Data.Bool"
show: "Data.Pair"
show: "Number.GF(p)"
show: "Number.Natural"

def {
  package: gfp-div-def-1.22
}

thm {
  import: def
  package: gfp-div-thm-1.18
}

gcd {
  import: def
  import: thm
  package: gfp-div-gcd-1.13
}

main {
  import: def
  import: thm
  import: gcd
}