name: list-quant
version: 1.7
description: Definitions and theorems about list quantifiers
author: Joe Hurd <joe@gilith.com>
license: MIT
show: "Data.Bool"
show: "Data.List"
show: "Function"

def {
  package: list-quant-def-1.8
}

thm {
  import: def
  package: list-quant-thm-1.8
}

main {
  import: def
  import: thm
}
