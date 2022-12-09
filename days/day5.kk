module day5

import std/text/parse

import utils/input
import utils/map
import utils/misc

fun split-input(inp: list<string>): pure (list<string>, list<string>)
  inp.split-at-first fn (s) { s == "" }

alias stack = (int, list<char>)
alias movement = (int, int, int)

fun parse-item(): parse char
  char('[')
  val item = alpha()
  char(']')
  item

fun parse-stack(): parse stack
  whitespace()
  val id = pint()
  whitespace()
  val items =
    many
      val item = parse-item()
      whitespace()
      item

  (id, items.reverse)

fun parse-movement(): parse movement
  pstring("move")
  whitespace()
  val qty = pint()
  whitespace()
  pstring("from")
  whitespace()
  val src = pint()
  whitespace()
  pstring("to")
  whitespace()
  val dst = pint()
  (qty, src, dst)

pub fun get-parsed-input(): io (int, map<int, list<char>>, list<movement>)
  match get-input-lines(5).split-input
    (rows, movements) -> 
      val init-stacks = rows
        .map(fn (r) { (r ++ " ").slice.to-list-char.partition-n(4).map(string) })
        .transpose
        .map(reverse)
        .map(join)
        .map(fn (s) { s.slice.parse(parse-stack).maybe.default((-1, [])) })

      val stacks = init-stacks.length

      val parsed-movements = movements.map(fn (m) { m.slice.parse(parse-movement).maybe.default((-1, -1, -1)) })

      val s-a-m = init-stacks.foldl(empty()) fn (acc, x)
        match x
          (id, stk) -> acc.insert(id, stk, compare)

      (stacks, s-a-m, parsed-movements)

pub fun apply-movement-single(stks: map<int, list<char>>, from: int, to: int): pure map<int, list<char>>
  val fstk = stks.get-raw(from, compare)
  val tstk = stks.get-raw(to, compare)

  match fstk
    Nil         -> throw("Nothing to move!")
    Cons(x, xs) ->
      val ntstk = Cons(x, tstk)
      stks
        .alter(from, compare, fn (_) { Just(xs) })
        .alter(to, compare, fn (_) { Just(ntstk) })

pub fun apply-movement-multi(stks: map<int, list<char>>, qty: int, from: int, to: int): pure map<int, list<char>>
  val fstk = stks.get-raw(from, compare)
  val tstk = stks.get-raw(to, compare)

  match fstk.split(qty)
    (hd, tl) ->
      stks
        .alter(from, compare, fn (_) { Just(tl) })
        .alter(to, compare, fn (_) { Just(hd ++ tstk) })

pub fun move-stk(stks: map<int, list<char>>, mv: movement, multi: bool): pure map<int, list<char>>
  match mv
    (0, _, _)     -> stks
    (n, from, to) ->
      if multi
      then
        stks.apply-movement-multi(n, from, to)
      else
        val nstks = stks.apply-movement-single(from, to)
        nstks.move-stk((n - 1, from, to), multi)

pub fun apply-moves(stks: map<int, list<char>>, mvs: list<movement>, multi: bool): pure map<int, list<char>>
  mvs.foldl(stks) fn (s, m)
    s.move-stk(m, multi)

pub fun get-tops(stks: map<int, list<char>>, maxid: int): pure string
  fold-int(1, maxid + 1, Nil, fn (id, acc) {
    Cons(stks.get-raw(id, compare).head.default(' '), acc)
  }).reverse.string

pub fun day5(part: int): io ()
  match part
    1 -> match get-parsed-input()
      (maxid, stks, mvs) ->
        stks.apply-moves(mvs, False).get-tops(maxid).println
    2 -> match get-parsed-input()
      (maxid, stks, mvs) ->
        stks.apply-moves(mvs, True).get-tops(maxid).println
    _ -> "Invalid part!".println
