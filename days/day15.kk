module day15

import std/text/parse

import utils/avl
import utils/input
import utils/iterative
import utils/misc
import utils/ord
import utils/ordlist
import utils/set

struct sensor
  location: (int, int)
  beacon: (int, int)
  exclusion-radius: int

fun manhattan(a: (int, int), b: (int, int)): int
  match (a, b)
    ((x1, y1), (x2, y2)) -> abs(x2 - x1) + abs(y2 - y1)

fun parse-sensor(): parse sensor
  pstring("Sensor at x=")
  val sx = pint()
  pstring(", y=")
  val sy = pint()
  pstring(": closest beacon is at x=")
  val bx = pint()
  pstring(", y=")
  val by = pint()

  Sensor((sx, sy), (bx, by), (sx, sy).manhattan((bx, by)))

fun excludes-on-row(sen: sensor, y: int): maybe<(int, int)>
  match sen
    Sensor((sx, sy), _, exc) ->
      // ... It's hard to explain how this works.
      // The difference between the row of the sensor and the target row
      // consumes a fixed amout of exclusion distance.
      // Then the remaining can go laterally on either direction, where
      // the "arms" coming from sx stretch by "remaining" on either side.
      val leeway = exc - abs(y - sy)
      if   leeway >= 0
      then Just((sx - leeway, sx + leeway))
      else Nothing

fun merge-ranges(ranges: list<(int, int)>): pure list<(int, int)>
  val sorted-ranges = ranges.qsort(fn (l, r) {
    match (l, r)
      ((l_, _), (r_, _)) -> l_.compare(r_)
  })

  fun merge(rrs: list<(int, int)>, stk: list<(int, int)>): pure list<(int, int)>
    match (rrs, stk)
      (Cons(r, rs), Nil)         ->
        merge(rs, [r])
      (Cons(r, rs), Cons(s, ss)) ->
        if   s.snd < r.fst then merge(rs, Cons(r, stk))
        elif s.snd < r.snd then merge(rs, Cons((s.fst, r.snd), ss))
        else                    merge(rs, stk)
      (Nil, _)                   ->
        stk

  sorted-ranges.merge(Nil)

// For finding the beacon sending the distress signal, we'll use an algorithm where we
// attempt to solve this statement:
//
//   ∃ x , y . (∀ s . s ∈ Sensors -> s.location.manhattan((x, y)) > s.exclusion-radius)
//
// This means we end up with a system of equations that look like:
//
//   |s1.location.x - x| + |s1.location.y - y| > s1.exclusion-radius
//   |s2.location.x - x| + |s2.location.y - y| > s2.exclusion-radius
//   ...                        AND SO ON                         ...
//   |sN.location.x - x| + |sN.location.y - y| > sN.exclusion-radius
//
// And this must be solved... somehow. However, we do already know that:
//
//   0 <= x <= 4000000
//   0 <= y <= 4000000
//
// Which doesn't really shrink our search space by much.
//
// It'd be nice to implement this some day.

fun range-size(range: (int, int), excludes: list<int> = Nil): int
  match range
    (s, e) -> (e - s) + 1 - excludes.count(fn (x) (x >= s) && (x <= e))

pub fun day15(part: int): io ()
  val sensor-objects = get-input-lines(15).flatmap(fn (line) {
      match line.slice.parse(parse-sensor)
        ParseOk(s, _)    -> [s]
        ParseError(_, _) -> []
    })

  // CHANGE THESE IF YOU WANT TO RUN THE EXAMPLE.
  val target-y = 2000000
  val search-params = (0, 4000000)

  val sensor-xs-on-target-y = sensor-objects
    .filter-map(fn (s) {
      val p = s.location
      if   p.snd == target-y
      then Just(p.fst)
      else Nothing
    })

  val beacon-xs-on-target-y = sensor-objects
    .filter-map(fn (s) {
      val p = s.beacon
      if   p.snd == target-y
      then Just(p.fst)
      else Nothing
    })

  val blocked = (sensor-xs-on-target-y ++ beacon-xs-on-target-y)
    .foldl(empty(), fn (acc, x) { with ord-int; acc.insert(x) })
    .fold([], fn (k, _, acc) { Cons(k, acc) })

  match part
    1 ->
      sensor-objects
        .filter-map(fn (s) s.excludes-on-row(target-y))
        .merge-ranges
        .foldl(0, fn (acc, r) { acc + r.range-size(blocked) })
        .println
    2 ->
      // TODO: Optimise this.
      with loop

      var y := 0
      ifor { y := search-params.fst } { y <= search-params.snd } { y := y + 1 } {
        val ranges = sensor-objects
          .filter-map(fn (s) s.excludes-on-row(y))
          .merge-ranges
        
        match ranges
          Cons((s2, _), Cons((_, e1), Nil)) ->
            val x = (e1 + s2) / 2
            ((x * search-params.snd) + y).println
            break()
          _                                   ->
            ()
      }
    _ -> "Invalid part!".println
