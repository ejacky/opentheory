name: list-quant
version: 1.0
description: Definitions and theorems about list quantifiers
author: Joe Hurd <joe@gilith.com>
license: OpenTheory
show: "Data.Bool"
show: "Data.List"
show: "Function"

def {
  package: list-quant-def-1.0
}

thm {
  import: def
  package: list-quant-thm-1.0
}

main {
  import: def
  import: thm
}