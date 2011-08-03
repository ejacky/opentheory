name: natural-add
version: 1.11
description: Definitions and theorems about natural number addition
author: Joe Hurd <joe@gilith.com>
license: MIT
show: "Data.Bool"
show: "Number.Natural"

def {
  package: natural-add-def-1.4
}

thm {
  import: def
  package: natural-add-thm-1.3
}

numeral {
  import: thm
  package: natural-add-numeral-1.2
}

suc {
  import: thm
  import: numeral
  package: natural-add-suc-1.2
}

order {
  import: thm
  package: natural-add-order-1.10
}

main {
  import: def
  import: thm
  import: numeral
  import: suc
  import: order
}
