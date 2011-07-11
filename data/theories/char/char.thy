name: char
version: 1.15
description: Theory of Unicode characters
author: Joe Hurd <joe@gilith.com>
license: MIT
show: "Data.Bool"
show: "Data.Byte" as "Byte"
show: "Data.Char"
show: "Data.List"
show: "Data.Option" as "Option"
show: "Data.Pair"
show: "Data.Word16" as "Word16"
show: "Number.Natural" as "Natural"
show: "Number.Numeral"
show: "Parser"

def {
  package: char-def-1.13
}

thm {
  import: def
  package: char-thm-1.0
}

utf8 {
  import: def
  import: thm
  package: char-utf8-1.14
}

main {
  import: def
  import: thm
  import: utf8
}
