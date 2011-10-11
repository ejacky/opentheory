name: function
version: 1.10
description: Basic theory of functions
author: Joe Hurd <joe@gilith.com>
license: MIT
show: "Data.Bool"
show: "Function"

def {
  package: function-def-1.4
}

thm {
  import: def
  package: function-thm-1.9
}

main {
  import: def
  import: thm
}
