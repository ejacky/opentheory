name: function
version: 1.27
description: Function operators and combinators
author: Joe Hurd <joe@gilith.com>
license: MIT
requires: bool
show: "Data.Bool"
show: "Function"

def {
  package: function-def-1.10
}

thm {
  import: def
  package: function-thm-1.22
}

main {
  import: def
  import: thm
}
