name: natural-distance
version: 1.5
description: Natural number distance function
author: Joe Hurd <joe@gilith.com>
license: MIT
show: "Data.Bool"
show: "Number.Natural"

def {
  package: natural-distance-def-1.8
}

thm {
  import: def
  package: natural-distance-thm-1.9
}

main {
  import: def
  import: thm
}