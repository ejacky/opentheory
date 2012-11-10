name: word16-bytes
version: 1.77
description: 16-bit word to byte pair conversions
author: Joe Leslie-Hurd <joe@gilith.com>
license: MIT
requires: bool
requires: byte
requires: list
requires: natural
requires: pair
requires: word16-bits
requires: word16-def
show: "Data.Bool"
show: "Data.Byte"
show: "Data.Byte.Bits"
show: "Data.List"
show: "Data.Pair"
show: "Data.Word16"
show: "Data.Word16.Bits"
show: "Number.Natural"

def {
  package: word16-bytes-def-1.70
}

thm {
  import: def
  package: word16-bytes-thm-1.84
}

main {
  import: def
  import: thm
}
