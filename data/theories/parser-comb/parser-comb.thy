name: parser-comb
version: 1.6
description: Theory of the basic parser combinators
author: Joe Hurd <joe@gilith.com>
license: MIT
show: "Data.Bool"
show: "Data.List"
show: "Data.Option"
show: "Data.Pair"
show: "Parser"

def {
  package: parser-comb-def-1.8
}

thm {
  import: def
  package: parser-comb-thm-1.8
}

main {
  import: def
  import: thm
}
