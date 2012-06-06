name: natural-fibonacci
version: 1.21
description: Fibonacci numbers
author: Joe Hurd <joe@gilith.com>
license: MIT
requires: base
requires: probability
requires: stream
show: "Data.Bool"
show: "Data.List"
show: "Data.Pair"
show: "Data.Stream"
show: "Function"
show: "Number.Natural"
show: "Number.Natural.Fibonacci"
show: "Probability.Random"
show: "Relation"

exists {
  package: natural-fibonacci-exists-1.9
}

def {
  import: exists
  package: natural-fibonacci-def-1.14
}

thm {
  import: exists
  import: def
  package: natural-fibonacci-thm-1.18
}

main {
  import: def
  import: thm
}