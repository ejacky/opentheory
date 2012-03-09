name: gfp-div-gcd-thm
version: 1.20
description: Properties of a gcd-based GF(p) division algorithm
author: Joe Hurd <joe@gilith.com>
license: MIT
provenance: HOL Light theory extracted on 2012-03-08
requires: bool
requires: natural
requires: natural-gcd
requires: natural-prime
requires: gfp-witness
requires: gfp-def
requires: gfp-thm
requires: gfp-div-def
requires: gfp-div-thm
requires: gfp-div-gcd-def
show: "Data.Bool"
show: "Number.GF(p)"
show: "Number.Natural"

main {
  article: "gfp-div-gcd-thm.art"
}
