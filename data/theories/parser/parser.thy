name: parser
version: 1.129
description: Stream parsers
author: Joe Leslie-Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: function
requires: list
requires: natural
requires: option
requires: pair
requires: probability
requires: relation
show: "Data.Bool"
show: "Data.List"
show: "Data.Option"
show: "Data.Pair"
show: "Function"
show: "Number.Natural"
show: "Parser"
show: "Parser.Stream"
show: "Probability.Random"
show: "Relation"
haskell-int-file: haskell.int
haskell-src-file: haskell.art

stream {
  package: parser-stream-1.100
}

comb {
  import: stream
  package: parser-comb-1.91
}

all {
  import: stream
  import: comb
  package: parser-all-1.95
}

main {
  import: stream
  import: comb
  import: all
}
