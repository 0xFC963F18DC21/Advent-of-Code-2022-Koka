module day1

import std/text/parse

import utils/input
import utils/ord
import utils/ordlist

alias elf = list<int>

fun parse-elf(): <parse | e> elf
  val foods = many
    val food = pint()
    char('\n')
    food
  char('\n')
  foods

fun get-elves(input: string): list<elf>
  input.slice.parse {
    with many
    parse-elf()
  }.maybe.default([])

pub fun day1(part: int): io ()
  with fun cmp(l: int, r: int) r.compare(l)

  val elves = get-elves(get-input(1)).map(sum).qsort
  match part
    1 -> elves.head(0).show.println
    2 -> elves.take(3).sum.show.println
    _ -> "Invalid part!".println
