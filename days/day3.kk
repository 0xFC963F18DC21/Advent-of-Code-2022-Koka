module day3

import std/text/parse

import utils/input
import utils/misc
import utils/avl
import utils/set

fun get-common-item1(rucksack: string): pure char
  val rlist = rucksack.slice.to-list-char

  match rlist.split(rucksack.count / 2)
    (l, r) ->
      val iset = l.foldl(empty()) fn (s, c) {
        s.insert(c, compare)
      }

      r.find fn (c) {
        iset.contains(c, compare)
      }.default('\t')

fun get-common-item2(rucksacks: list<string>): pure char
  val rlists = rucksacks.map fn (s) {
    s.slice.to-list-char
  }

  val sets = rlists.map fn (l) {
    l.foldl(empty()) fn (s, c) {
      s.insert(c, compare)
    }
  }

  val intersection = sets.foldl1 fn (l, r) {
    l.intersect(r, compare)
  }

  intersection.any().default(('\t', False)).fst

fun priority(c: char): int
  if   c.is-upper
  then (c - 'A').int + 27
  else (c - 'a').int + 1

pub fun day3(part: int): io ()
  val input = get-input-lines(3)
  match part
    1 -> input.map(fn (x) { x.get-common-item1.priority }).sum.println
    2 -> input.partition-n(3).map(fn (x) { x.get-common-item2.priority }).sum.println
    _ -> "Invalid part!".println
