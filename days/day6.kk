module day6

import utils/input
import utils/iterative
import utils/misc
import utils/set

fun is-st(tx-frag: string): pure bool
  with loop

  var cset   := empty()
  var sl     := tx-frag.slice
  var cur    := Nothing
  var result := True

  ifor { cur := sl.next } { result && !cur.is-nothing } { cur := sl.next }
    match cur
      Just((c, rest)) ->
        sl := rest
        if   cset.contains(c, compare)
        then result := False
        else cset := cset.insert(c, compare)

  result

fun find-st(tx: string, len: int): pure int
  fun fnstx(ss: list<string>, pos: int): pure int
    match ss
      Nil         -> -1
      Cons(x, xs) -> if   x.is-st
                     then pos
                     else xs.fnstx(pos + 1)

  tx.substring-n(len).fnstx(len)

pub fun day6(part: int): io ()
  val input = get-input-lines(6).head.default("")
  match part
    1 -> input.find-st(4).println
    2 -> input.find-st(14).println
    _ -> "Invalid part!".println
