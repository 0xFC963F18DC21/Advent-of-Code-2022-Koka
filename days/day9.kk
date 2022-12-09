module day9

import std/text/parse

import utils/eq
import utils/input
import utils/ord
import utils/set

pub type move
  U(amt: int)
  R(amt: int)
  D(amt: int)
  L(amt: int)

pub fun to-pairs(m: move): div list<(int, int)>
  match (m: move)
    U(a) -> (0, -1).replicate(a)
    R(a) -> (1, 0).replicate(a)
    D(a) -> (0, 1).replicate(a)
    L(a) -> (-1, 0).replicate(a)

pub fun parse-movement(): parse move
  fun pm(ch: char, cons: int -> move)
    fn ()
      char(ch)
      whitespace()
      val amt = pint()
      cons(amt)

  [pm('U', U), pm('R', R), pm('D', D), pm('L', L)].choose

pub fun parse-movements(): parse list<move>
  many
    val m = parse-movement()
    whitespace0()
    m

pub fun (+)(a: (int, int), b: (int, int)): (int, int)
  match (a, b)
    ((a1, a2), (b1, b2)) -> (a1 + b1, a2 + b2)

pub fun (-)(a: (int, int), b: (int, int)): (int, int)
  match (a, b)
    ((a1, a2), (b1, b2)) -> (a1 - b1, a2 - b2)

pub fun get-tail-movement(h: (int, int), t: (int, int)): exn (int, int)
  match h - t
    (-2, -2) -> (-1, -1)
    (-1, -2) -> (-1, -1)
    (0, -2)  -> (0, -1)
    (1, -2)  -> (1, -1)
    (2, -2)  -> (1, -1)

    (-2, -1) -> (-1, -1)
    (-2, 0)  -> (-1, 0)
    (-2, 1)  -> (-1, 1)

    (2, -1)  -> (1, -1)
    (2, 0)   -> (1, 0)
    (2, 1)   -> (1, 1)

    (-2, 2)  -> (-1, 1)
    (-1, 2)  -> (-1, 1)
    (0, 2)   -> (0, 1)
    (1, 2)   -> (1, 1)
    (2, 2)   -> (1, 1)

    _        -> (0, 0)

pub fun tail-movement-magnitude(mvts: list<(int, int)>, h: (int, int), t: (int, int), tps: set<(int, int)>): <pure, eq<(int, int)>, ord<(int, int)>> int
  match mvts
    Nil         -> tps.set-count()
    Cons(m, ms) ->
      val h_ = h + m
      val tm = get-tail-movement(h_, t)

      if   tm === (0, 0)
      then tail-movement-magnitude(ms, h_, t, tps)
      else
        val t_   = t + tm
        val tps_ = tps.insert(t_)
        tail-movement-magnitude(ms, h_, t_, tps_)

pub fun multi-knot-mm(mvts: list<(int, int)>, knots: list<(int, int)>, tpfs: set<(int, int)>): <pure, eq<(int, int)>, ord<(int, int)>> int
  fun update(ks: list<(int, int)>, upd: bool = False): <pure, eq<(int, int)>, ord<(int, int)>> (list<(int, int)>, set<(int, int)>)
    match ks
      Nil                  -> (Nil, tpfs)
      Cons(x, Nil)         -> (Cons(x, Nil), if upd then tpfs.insert(x) else tpfs)
      Cons(h, Cons(t, xs)) ->
        val tm = get-tail-movement(h, t)
        match update(Cons(t + tm, xs), tm !== (0, 0))
          (xs_, tpfs_) -> (Cons(h, xs_), tpfs_)

  fun map-head(l: list<a>, f: a -> e a): e list<a>
    match l
      Nil         -> Nil
      Cons(x, xs) -> Cons(f(x), xs)

  match mvts
    Nil         -> tpfs.set-count()
    Cons(m, ms) ->
      val knots_  = knots.map-head(fn (p) (p + m))
      match knots_.update
        (knots__, tpfs_) -> multi-knot-mm(ms, knots__, tpfs_)

pub fun day9(part: int): io ()
  with eq-int
  with ord-int
  with eq-pair
  with ord-pair

  val mvts = get-input(9).slice.parse(parse-movements).maybe.default([]).flatmap(to-pairs)

  match part
    1 -> mvts.tail-movement-magnitude((0, 0), (0, 0), empty().insert((0, 0))).println
    2 -> mvts.multi-knot-mm((0, 0).replicate(10), empty().insert((0, 0))).println
    _ -> "Invalid part!".println
