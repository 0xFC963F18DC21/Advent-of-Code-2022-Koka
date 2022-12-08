module day8

import std/text/parse

import utils/input
import utils/iterative
import utils/map
import utils/misc
import utils/ord

fun parse-line(): parse list<int>
  val line = many
    digit()
  char('\n')
  line

fun parse-grid(): parse list<list<int>>
  many
    parse-line()

fun day-grid(): io list<list<int>>
  val inp = get-input(8)
  match inp.last(1).next()
    Nothing         -> throw("Where's the input?")
    Just(('\n', _)) -> inp.slice.parse(parse-grid).maybe.default([])
    Just(_)         -> (inp ++ "\n").slice.parse(parse-grid).maybe.default([])

fun grid-as-map(grid: list<list<int>>): pure map<(int, int), int>
  with loop
  with ord-int
  with ord-pair

  val height = grid.length
  val width  = grid.head.default([]).length

  var x := 0
  var y := 0
  var m := empty()

  ifor { y := 0 } { y < height } { y := y + 1 } {
    ifor { x := 0 } { x < width } { x := x + 1 } {
      val item = grid[y].default([])[x].default(-1)
      m := m.insert((x, y), item)
    }
  }

  m

fun visible(grid: map<(int, int), int>, width: int, height: int, at: (int, int)): pure bool
  with loop
  with ord-int
  with ord-pair

  var vis := False

  match at
    (sx, sy) ->
      val stree = grid.get-raw((sx, sy))

      // If edge, don't check.
      if   (sx == 0) || (sy == 0) || (sx == width - 1) || (sy == height - 1)
      then vis := True
      else
        // -Y vis check.
        vis := (vis || incl-range(sy - 1, 0, -1).map(fn (y) (sx, y)).map(fn (c) grid.get-raw(c)).all(fn (h) h < stree))

        // -X vis check.
        vis := (vis || incl-range(sx - 1, 0, -1).map(fn (x) (x, sy)).map(fn (c) grid.get-raw(c)).all(fn (h) h < stree))

        // +Y vis check.
        vis := (vis || incl-range(sy + 1, height - 1, 1).map(fn (y) (sx, y)).map(fn (c) grid.get-raw(c)).all(fn (h) h < stree))

        // +X vis check.
        vis := (vis || incl-range(sx + 1, width - 1, 1).map(fn (x) (x, sy)).map(fn (c) grid.get-raw(c)).all(fn (h) h < stree))

  vis

fun scenic-score(grid: map<(int, int), int>, width: int, height: int, at: (int, int)): pure int
  with ord-int
  with ord-pair

  match at
    (sx, sy) ->
      val stree = grid.get-raw((sx, sy))

      fun find-scsc(cx: int, cy: int, dx: int, dy: int)
        if   (cx < 0) || (cy < 0) || (cx >= width) || (cy >= height) then 0
        elif grid.get-raw((cx, cy)) >= stree                         then 1
        else 1 + find-scsc(cx + dx, cy + dy, dx, dy)

      // -Y scsc check.
      val nscy = find-scsc(sx, sy - 1, 0, -1)

      // -X scsc check.
      val nscx = find-scsc(sx - 1, sy, -1, 0)

      // +Y scsc check.
      val pscy = find-scsc(sx, sy + 1, 0, 1)

      // +X scsc check
      val pscx = find-scsc(sx + 1, sy, 1, 0)

      nscy * nscx * pscy * pscx

fun count-visible(grid: map<(int, int), int>, width: int, height: int): pure int
  with loop

  var x := 0
  var y := 0

  // Start value is the perimeter of grid.
  var vis := (width * 2) + (height * 2) - 4
  ifor { y := 1 } { y < height - 1 } { y := y + 1 } {
    ifor { x := 1 } { x < width - 1 } { x := x + 1 } {
      if   grid.visible(width, height, (x, y))
      then vis := vis + 1
    }
  }

  vis

fun max-scenic(grid: map<(int, int), int>, width: int, height: int): pure int
  with loop

  var x := 0
  var y := 0

  // Start value is the perimeter of grid.
  var msc := 0
  ifor { y := 1 } { y < height - 1 } { y := y + 1 } {
    ifor { x := 1 } { x < width - 1 } { x := x + 1 } {
      msc := max(msc, grid.scenic-score(width, height, (x, y)))
    }
  }

  msc

pub fun day8(part: int): io ()
  val grid   = day-grid()

  val height = grid.length
  val width  = grid.head.default([]).length

  val as-map = grid.grid-as-map()

  match part
    1 -> as-map.count-visible(width, height).println
    2 -> as-map.max-scenic(width, height).println
    _ -> "Invalid part!".println
