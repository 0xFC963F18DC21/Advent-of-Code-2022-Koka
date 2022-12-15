module day14

import std/text/parse

import utils/eq
import utils/input
import utils/iterative
import utils/misc
import utils/ord
import utils/set

alias rock-path = list<(int, int)>

effect max-y
  fun attempt-lower(ny: int): ()
  fun get-max(): int

fun parse-path(): <div, parse, max-y> rock-path
  fun parse-coords()
    val x = pint()
    char(',')
    val y = pint()
    attempt-lower(y)
    (x, y)

  many
    val node = parse-coords()
    optional(" -> ") { pstring(" -> ") }
    node

fun complete-rock-path(p: rock-path): div rock-path
  p.zip(p.tail).flatmap fn (p_) {
    match p_
      ((x1, y1), (x2, y2)) ->
        if   x1 != x2
        then incl-range(x1, x2, signum(x2 - x1)).map(fn (x) (x, y1)) // Assumes y1 == y2.
        else incl-range(y1, y2, signum(y2 - y1)).map(fn (y) (x1, y)) // Assumes x1 == x2.
  }

fun make-obstacle-set(ps: list<rock-path>): pure set<(int, int)>
  with ord-int
  with ord-pair

  ps.foldl(empty()) fn (acc, p)
    p.complete-rock-path.foldl(acc) fn (acc_, c)
      acc_.insert(c)

fun simulate-sand(obstacles: set<(int, int)>, until-source-blocked: bool): <max-y, io> int
  with loop
  with label-loop

  with ord-int
  with ord-pair

  with eq-int
  with eq-pair

  fun (+++)(l: (int, int), r: (int, int)): (int, int)
    match (l, r)
      ((l1, r1), (l2, r2)) -> (l1 + l2, r1 + r2)

  var cgr    := (-1, -1)
  var grains := 0
  var oset   := obstacles

  val attempts = [(0, 1), (-1, 1), (1, 1)]

  label-while("outer-simulation") { True } {
    // Summon a new grain.
    cgr := (500, 0)

    iwhile { True } {
      // Attempt to move down, rest if can't.
      match attempts.find-e(fn (m) !oset.contains(cgr +++ m))
        Just(m) ->
          cgr := (cgr +++ m)

          // If we're waiting until the outer source is blocked, don't break here.
          if   !until-source-blocked && (cgr.snd >= get-max())
          then label-break("outer-simulation")

          // This is the floor. Stop the sand here.
          if until-source-blocked && (cgr.snd >= (get-max() + 1)) then
            oset   := oset.insert(cgr)
            grains := grains + 1
            break()
        Nothing ->
          oset   := oset.insert(cgr)
          grains := grains + 1

          if   until-source-blocked && (cgr === (500, 0))
          then label-break("outer-simulation")
          else break()
    }
  }

  grains

pub fun day14(part: int): io ()
  var lowest-y := 0

  with handler
    fun attempt-lower(ny: int)
      lowest-y := max(lowest-y, ny)
    fun get-max()
      lowest-y

  val initial-oset = get-input-lines(14).flatmap(fn (line) {
      match line.slice.parse(parse-path)
        ParseOk(p, _)    -> [p]
        ParseError(_, _) -> []
    })
    .make-obstacle-set

  match part
    1 -> initial-oset.simulate-sand(False).println
    2 -> initial-oset.simulate-sand(True).println
    _ -> "Invalid part!".println
