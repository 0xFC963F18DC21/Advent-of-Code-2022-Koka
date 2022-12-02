module day1

import std/text/parse

import day-input
import day-utils

alias elf = list<int>

fun parse-elf(): <parse | e> elf
  val foods = many
    val food = pint()
    with return(x) food
    pstring("\n")
  with return(x) foods
  pstring("\n")

fun get-elves(input: string): list<elf>
  input.slice.parse {
    with many
    parse-elf()
  }.maybe.default([])

pub fun day1(part: int): io ()
  val elves = get-elves(get-input(1)).map(sum).qsort(compare)
  match part
    1 -> elves.head(0).show.println
    2 -> elves.take(3).sum.show.println
    _ -> "Invalid part!".println
