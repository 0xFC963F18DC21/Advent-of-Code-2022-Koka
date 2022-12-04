module day4

import std/text/parse

import utils/input
import utils/misc

alias assignment = (int, int)

fun parse-assignment(): <parse | e> assignment
  val lb = pint()
  char('-')
  val ub = pint()
  (lb, ub)

fun parse-assignment-pair(): <parse | e> (assignment, assignment)
  val l = parse-assignment()
  char(',')
  val r = parse-assignment()

  optional('\n')
    char('\n')

  (l, r)

fun parse-all-assignment-pairs(): <parse | e> list<(assignment, assignment)>
  many
    parse-assignment-pair()

fun contained(l: assignment, r: assignment): bool
  match (l, r)
    ((llb, lub), (rlb, rub)) ->
      (llb >= rlb && lub <= rub) || (rlb >= llb && rub <= lub)

fun overlaps(l: assignment, r: assignment): bool
  match (l, r)
    ((llb, lub), (rlb, rub)) ->
      (llb <= rub) && (lub >= rlb)

pub fun day4(part: int): io ()
  val apairs = get-input(4).slice.parse(parse-all-assignment-pairs).maybe.default([])
  match part
    1 ->
      apairs.count fn (apair) {
        contained(apair.fst, apair.snd)
      }.show.println
    2 ->
      apairs.count fn (apair) {
        overlaps(apair.fst, apair.snd)
      }.show.println
    _ -> "Invalid part!".println
