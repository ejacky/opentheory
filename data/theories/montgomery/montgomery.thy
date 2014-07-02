name: montgomery
version: 1.18
description: Montgomery multiplication
author: Joe Leslie-Hurd <joe@gilith.com>
license: MIT
provenance: HOL Light theory extracted on 2012-11-09
requires: bool
requires: hardware
requires: natural
requires: natural-bits
requires: natural-divides
requires: set
show: "Data.Bool"
show: "Data.List"
show: "Hardware"
show: "Number.Natural"
show: "Set"

def {
  package: montgomery-def-1.7
}

thm {
  import: def
  package: montgomery-thm-1.17
}

hardware {
  import: thm
  package: montgomery-hardware-1.0
}

main {
  import: def
  import: thm
  import: hardware
}
