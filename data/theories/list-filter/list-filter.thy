name: list-filter
version: 1.8
description: Definitions and theorems about the list filter function
author: Joe Hurd <joe@gilith.com>
license: MIT
show: "Data.Bool"
show: "Data.List"
show: "Function"

def {
  package: list-filter-def-1.8
}

thm {
  import: def
  package: list-filter-thm-1.9
}

main {
  import: def
  import: thm
}
