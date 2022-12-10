module day10

import std/text/parse

import utils/input

type instr
  Noop
  AddX(amt: int)

fun show(i: instr): string
  match i
    Noop    -> "noop"
    AddX(x) -> "addx " ++ x.show

fun parse-instr(): parse instr
  fun noop()
    pstring("noop")
    Noop

  fun addx()
    pstring("addx")
    whitespace()
    AddX(pint())

  noop || addx

fun parse-all-instrs(): parse list<instr>
  many
    val i = parse-instr()
    whitespace0()
    i

fun get-instrs(): io list<instr>
  get-input(10).slice.parse(parse-all-instrs).maybe.default([])

fun enrich(insts: list<instr>): list<instr>
  insts.flatmap fn (x)
    match x
      Noop    -> [Noop]
      AddX(n) -> [Noop, AddX(n)]

fun signal-strength(insts: list<instr>): int
  insts.foldl(1) fn (acc, x)
    match x
      Noop    -> acc
      AddX(n) -> acc + n

fun get-six-signal-sum(insts: list<instr>): io int
  val enriched = insts.enrich
  val sublists = [19, 59, 99, 139, 179, 219].map(fn (x) (x + 1, enriched.take(x)))

  sublists.foldl(0) fn (acc: int, x)
    match x
      (cyc, is) ->
        acc + (is.signal-strength * cyc)

fun render(insts: list<instr>): io ()
  var buf := Nil

  fun print-all(iis, ctr, reg-x)
    if   ctr == 0
    then
      println(buf.string)
      buf := Nil
      iis.print-all(40, reg-x)
    else
      val pos = 40 - ctr

      if   (pos >= (reg-x - 1)) && (pos <= (reg-x + 1))
      then buf := buf ++ ['█']
      else buf := buf ++ [' ']

      match iis
        Nil         -> ()
        Cons(i, is) -> match i
          Noop    -> is.print-all(ctr - 1, reg-x)
          AddX(n) -> is.print-all(ctr - 1, reg-x + n)

  insts.enrich.print-all(40, 1)

pub fun day10(part: int): io ()
  val insts = get-instrs()
  match part
    1 -> insts.get-six-signal-sum.println
    2 -> insts.render
    _ -> "Invalid part!".println
