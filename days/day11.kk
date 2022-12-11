module day11

import std/text/parse

import utils/deque
import utils/input
import utils/iterative
import utils/misc
import utils/ordlist

pub struct monkey
  items: deque<int>
  oper: int -> int
  test: int -> bool
  decide: bool -> int

effect divisibility
  fun change-mod(f: int -> int): ()
  fun global-mod(): int

effect monkey-business
  fun get-monkey(id: int): (int, monkey)
  fun put-monkey(id: int, monkey: (int, monkey)): ()

pub fun parse-monkey(): <divisibility, parse> monkey
  // Get ID. (NOT NEEDED)
  pstring("Monkey")
  whitespace()
  pnat()
  char(':')
  whitespace()

  // Get starting items.
  pstring("Starting")
  whitespace()
  pstring("items:")
  whitespace()
  val items = chars-are("???", fn (c) { c != '\n' && c != '\r' }).string.split(", ").map(fn (s) { s.slice.parse(pnat).maybe.default(-1) })
  whitespace()

  // Get operation.
  pstring("Operation:")
  whitespace()
  pstring("new")
  whitespace()
  char('=')
  whitespace()
  pstring("old")
  whitespace()
  val op = [fn () {
    char('+')
    fn (a: int, b: int) a + b
  }, fn () {
    char('*')
    fn (a: int, b: int) a * b
  }].choose
  whitespace()
  val orhs = [fn () {
    val n = pnat()
    Just(n)
  }, fn () {
    pstring("old")
    Nothing
  }].choose
  whitespace()

  // Get test.
  pstring("Test:")
  whitespace()
  pstring("divisible")
  whitespace()
  pstring("by")
  whitespace()
  val trhs = pnat()
  change-mod(fn (x) (x * trhs))
  val test = fn (x) { (x % trhs) == 0 }
  whitespace()

  // Get decisions.
  pstring("If")
  whitespace()
  pstring("true:")
  whitespace()
  pstring("throw")
  whitespace()
  pstring("to")
  whitespace()
  pstring("monkey")
  whitespace()
  val tc = pnat()
  whitespace()

  pstring("If")
  whitespace()
  pstring("false:")
  whitespace()
  pstring("throw")
  whitespace()
  pstring("to")
  whitespace()
  pstring("monkey")
  whitespace()
  val fc = pnat()

  val decid = fn (b) { if b then tc else fc }

  Monkey(items.deque-from-list, fn (x) {
    match orhs
      Just(rhs) -> op(x, rhs)
      Nothing   -> op(x, x)
  }, test, decid)

fun test-parser()
  val ts = "Monkey 0:\n  Starting items: 79, 98\n  Operation: new = old * 19\n  Test: divisible by 23\n    If true: throw to monkey 2\n    If false: throw to monkey 3"
  val res = ts.slice.parse(parse-monkey)

  match res
    ParseError(msg, rest) ->
      println("ERROR")
      println(msg)
      println(rest.string)
    ParseOk(_, _)         ->
      println("All good!")

fun parse-monkeys(): <divisibility, parse> vector<(int, monkey)>
  many {
    val m = parse-monkey()
    whitespace0()
    (0, m)
  }.vector

pub fun get-input-monkeys(): <divisibility, io> vector<(int, monkey)>
  get-input(11).slice.parse(parse-monkeys).maybe.default(Nil.vector)

fun run-monkey(id: int, div3: bool): <divisibility, monkey-business, pure> ()
  match get-monkey(id)
    (inspects, Monkey(xs, op, tst, dec)) ->
      if   xs.is-empty()
      then ()
      else match dequeue-front(xs)
        (Just(x), xs_) ->
          val worry    = (if div3 then x.op / 3 else x.op) % global-mod()
          val throw-to = worry.tst.dec

          val this-monkey  = (inspects + 1, Monkey(xs_, op, tst, dec))
          val other-monkey = match get-monkey(throw-to)
            (i_, Monkey(ys, op_, tst_, dec_)) -> (i_, Monkey(ys.snoc(worry), op_, tst_, dec_))

          put-monkey(id, this-monkey)
          put-monkey(throw-to, other-monkey)

          run-monkey(id, div3)
        _              ->
          throw("You shouldn'tve gotten here!")

pub fun round(monkeys: vector<(int, monkey)>, cnt: int, div3: bool): <divisibility, pure> vector<(int, monkey)>
  var ms := monkeys

  with handler
    fun get-monkey(id: int)
      ms[id]

    fun put-monkey(id: int, monkey: (int, monkey))
      ms[id] := monkey

  incl-range(0, cnt - 1).foreach fn (id)
    run-monkey(id, div3)

  ms

pub fun day11(part: int): io ()
  var glob-mod := 1

  with handler
    fun change-mod(f: int -> int)
      glob-mod := f(glob-mod)

    fun global-mod()
      glob-mod

  val monkeys = get-input-monkeys()
  val cnt = monkeys.length

  fun simulate(rounds: int, div3: bool)
    incl-range(1, rounds, 1)
      .foldl(monkeys, fn (ms, _) { ms.round(cnt, div3) })
      .list
      .map(fn (x) { x.fst })
      .qsort(fn (a: int, b: int) b.compare(a))
      .take(2)
      .foldl1((*))
      .println

  match part
    1 -> simulate(20, True)
    2 -> simulate(10000, False)
    _ -> "Invalid part!".println
