name: bool-true
version: 1.0
description: The Boolean true constant
author: Joe Leslie-Hurd <joe@gilith.com>
license: MIT
show: "Data.Bool"

def {
  package: bool-true-def-1.0
}

thm {
  import: def
  package: bool-true-thm-1.0
}

main {
  import: def
  import: thm
}
