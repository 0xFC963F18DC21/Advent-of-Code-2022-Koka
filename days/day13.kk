module day13

import std/text/parse

import utils/input
import utils/misc
import utils/ord
import utils/ordlist

type nested<a>
  Flat(x: a)
  Nested(xs: list<nested<a>>)

alias packet = nested<int>

fun show-nested(xs: nested<a>, show: a -> <div | e> string): <div | e> string
  match xs
    Flat(x)     -> x.show
    Nested(xs_) -> xs_.show-list(fn (x) x.show-nested(show))

fun parse-packet(): <div, parse> packet
  fun pflat()
    Flat(pint())

  fun pnested()
    char('[')
    val items = many
      val item = parse-packet()
      optional(',') { char(',') }
      item
    char(']')
    Nested(items)

  [pflat, pnested].choose

fun ord-packet(action)
  fun cmp-p(l: packet, r: packet)
    match (l, r)
      (Flat(a), Flat(b))       ->
        with ord-int
        a.cmp(b)
      (Nested(xs), Nested(ys)) ->
        with fun cmp(l_: packet, r_: packet) l_.cmp-p(r_)
        with ord-list
        xs.cmp(ys)
      (Flat(x), ys)            ->
        Nested([Flat(x)]).cmp-p(ys)
      (xs, Flat(y))            ->
        xs.cmp-p(Nested([Flat(y)]))

  with fun cmp(l: packet, r: packet) l.cmp-p(r)

  action()

pub fun day13(part: int): io ()
  with ord-packet

  val input-pairs = get-input-lines(13).flatmap(fn (line) {
      match line.slice.parse(parse-packet)
        ParseOk(r, _)    -> [r]
        ParseError(_, _) -> []
    })

  match part
    1 -> input-pairs
      .partition-n(2)
      .map(fn (p) {
        match p
          Cons(l, Cons(r, Nil)) -> (l, r)
      })
      .map-indexed(fn (ix, p) (ix + 1, p))
      .filter-map(fn (p) {
        match p
          (ix, (l, r)) -> if l ~< r then Just(ix) else Nothing
      })
      .foldl(0, (+))
      .println
    2 -> (input-pairs ++ [Nested([Nested([Flat(2)])]), Nested([Nested([Flat(6)])])])
      .qsort
      .map-indexed(fn (ix, p) (ix + 1, p))
      .filter-map(fn (p) {
        match p
          (ix, Nested([Nested([Flat(2)])])) -> Just(ix)
          (ix, Nested([Nested([Flat(6)])])) -> Just(ix)
          _                                 -> Nothing
      })
      .foldl(1, (*))
      .println
    _ -> "Invalid part!".println
