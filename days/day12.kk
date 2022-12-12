module day12

import utils/deque
import utils/eq
import utils/input
import utils/iterative
import utils/map
import utils/misc
import utils/ord
import utils/ordlist
import utils/pqueue

effect pathfinder
  fun add-start(c: (int, int)): ()
  fun get-current-start(): (int, int)

  fun set-end(c: (int, int)): ()
  fun get-end(): (int, int)

  fun get-possible-moves(c: (int, int)): list<(int, int)>

  fun distance-heuristic(c: (int, int)): int

fun get-input-grid(consider-all: bool): <io, pathfinder> map<(int, int), int>
  with loop
  with ord-int
  with ord-pair

  var result := empty()

  val inp-lines  = get-input-lines(12).map(fn (s) s.slice.to-list-char)
  val inp-height = inp-lines.length
  val inp-width  = inp-lines.head.default([]).length

  var x := 0
  var y := 0

  ifor { y := 0 } { y < inp-height } { y := y + 1 } {
    ifor { x := 0 } { x < inp-width } { x := x + 1 } {
      val cell = inp-lines[y].default([])[x].default('\t')

      match cell
        '\t' -> throw("Oops, out of range!")
        'S'  ->
          add-start((x, y))
          result := result.insert((x, y), 0)
        'E'  ->
          set-end((x, y))
          result := result.insert((x, y), ('z' - 'a').int)
        _    ->
          if   consider-all && (cell == 'a')
          then add-start((x, y))

          result := result.insert((x, y), (cell - 'a').int)
    }
  }

  result

// Uses A* Pathfinding based on https://www.redblobgames.com/pathfinding/a-star/introduction.html
fun navigate(): <pure, iterative, eq<(int, int)>, ord<(int, int)>, pathfinder> map<(int, int), (int, int)>
  fun cmp-prio(l: (int, a), r: (int, a)): order
    l.fst.compare(r.fst)

  var frontier  := empty(cmp-prio)
  var came-from := empty()
  var costs     := empty()

  frontier := frontier.enqueue((0, get-current-start()))
  costs    := costs.insert(get-current-start(), 0)

  iwhile { !frontier.is-empty } {
    match frontier.dequeue()
      (Just((_, current)), frontier_) ->
        // Put the new queue and increment steps.
        frontier := frontier_

        // If goal, break.
        if   current === get-end()
        then break()

        // Otherwise...
        with next <- get-possible-moves(current).foreach

        // +1 added to emulate steps from start.
        val new-cost = costs.get-raw(current) + distance-heuristic(next) + 1
        if   (costs.get(next).is-nothing) || (new-cost < costs.get-raw(next))
        then
          costs     := costs.insert(next, new-cost)
          frontier  := frontier.enqueue((new-cost, next))
          came-from := came-from.insert(next, current)
  }

  came-from

fun (+++)(l: (int, int), r: (int, int)): (int, int)
  match (l, r)
    ((ll, lr), (rl, rr)) -> (ll + rl, lr + rr)

fun get-min-steps(consider-all: bool): io int
  with loop
  with eq-int
  with eq-pair
  with ord-int
  with ord-pair

  var start := Nil
  var cs    := (-1, -1)
  var steps := 99999999999999999999999999999999999999
  var end   := (-1, -1)
  var grid  := empty()

  fun manhe(c: (int, int))
    match (c, end)
      ((cx, cy), (ex, ey)) ->
        val dx = ex - cx
        val dy = ey - cy
        dx.abs + dy.abs

  with handler
    fun add-start(c)
      start := Cons(c, start)
    fun get-current-start()
      match cs
        (-1, -1) ->
          cs := start.minimum-by(fn (l, r) { l.manhe.compare(r.manhe) })
          cs
        _        ->
          cs

    fun set-end(c)
      end := c
    fun get-end()
      end

    fun get-possible-moves(c)
      val ch = grid.get-raw(c)

      with p <- [(0, -1), (1, 0), (0, 1), (-1, 0)].map(fn (d) { c +++ d }).filter

      val ch_ = grid.get(p)
      match ch_
        Nothing    -> False
        Just(ch__) -> ch__ <= (ch + 1)

    fun distance-heuristic(c)
      c.manhe

  // Get the input grid and initialise the start and end coordinates.
  grid := get-input-grid(consider-all)

  iwhile { !start.is-empty } {
    // Perform navigation.
    val path = navigate()

    // Backtrack to find step count.
    fun back(c: (int, int))
      if   c === get-current-start()
      then 0
      else match path.get(c)
        Just(c_) -> 1 + c_.back
        Nothing  -> 99999999999999999999999999999999999999 // Practically infinite.

    val this-steps = get-end().back
    println("STEPS FOUND FROM (" ++ get-current-start().fst.show ++ ", " ++ get-current-start().snd.show ++ ") = " ++ this-steps.show)

    // TODO: Optimise
    steps := steps.min(this-steps)
    start := start.remove-e(fn (s) { s === get-current-start() }, True)
    cs    := (-1, -1)
  }

  steps

pub fun day12(part: int): io ()
  match part
    1 -> get-min-steps(False).println
    2 -> get-min-steps(True).println
    _ -> "Invalid part!".println
