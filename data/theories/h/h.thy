name: h
version: 1.8
description: The memory safety proof of the H API
author: Joe Hurd <joe@gilith.com>
license: MIT
show: "Data.Bool"
show: "Data.List"

def {
  package: h-def-1.10
}

thm {
  import: def
  package: h-thm-1.10
}

main {
  import: def
  import: thm
}
