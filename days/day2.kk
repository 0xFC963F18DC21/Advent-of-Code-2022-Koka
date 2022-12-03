module day2

import std/text/parse

import utils/input

type rps
  Rock
  Paper
  Scissors

fun (==)(lr: rps, rr: rps): bool
  match (lr, rr)
    (Rock, Rock)         -> True
    (Paper, Paper)       -> True
    (Scissors, Scissors) -> True
    _                    -> False

fun int(move: rps): int
  match move
    Rock     -> 1
    Paper    -> 2
    Scissors -> 3

type rps-status
  Loss
  Draw
  Win

fun int(status: rps-status): int
  match status
    Loss -> 0
    Draw -> 3
    Win  -> 6

pub fun parse-rps(): <parse | e> rps
  fun rock() {
    one-of("AX")
    Rock
  }

  fun paper() {
    one-of("BY")
    Paper
  }

  fun scissors() {
    one-of("CZ")
    Scissors
  }

  [rock, paper, scissors].choose

fun parse-rps-status(): <parse | e> rps-status
  fun loss() {
    char('X')
    Loss
  }

  fun draw() {
    char('Y')
    Draw
  }

  fun win() {
    char('Z')
    Win
  }

  [loss, draw, win].choose

fun parse-p1(): <parse | e> (rps, rps)
  val o = parse-rps()
  whitespace()
  val y = parse-rps()
  char('\n')
  (o, y)

fun parse-p2(): <parse | e> (rps, rps-status)
  val o = parse-rps()
  whitespace()
  val g = parse-rps-status()
  char('\n')
  (o, g)

fun rps-match(opp: rps, you: rps): rps-status
  match (opp, you)
    (Rock, Paper)     -> Win
    (Paper, Scissors) -> Win
    (Scissors, Rock)  -> Win
    (x, y) ->
      if   x == y
      then Draw
      else Loss

fun get-intended(opp: rps, goal: rps-status): <exn | e> rps
  // This catches all cases but Koka is not convinced.
  match (opp, goal)
    (Rock, Win)      -> Paper
    (Paper, Win)     -> Scissors
    (Scissors, Win)  -> Rock
    (Rock, Loss)     -> Scissors
    (Paper, Loss)    -> Rock
    (Scissors, Loss) -> Paper
    (x, Draw)        -> x

fun get-score1(opp: rps, you: rps): int
  you.int + opp.rps-match(you).int

fun get-score2(opp: rps, goal: rps-status): <exn | e> int
  opp.get-intended(goal).int + goal.int

pub fun day2(part: int): io ()
  val input = get-input(2)
  match part
    1 -> input.slice.parse {
      with many
      parse-p1()
    }.maybe.default([]).map(fn ((o, y)) { get-score1(o, y) }).sum.println
    2 -> input.slice.parse {
      with many
      parse-p2()
    }.maybe.default([]).map(fn ((o, g)) { get-score2(o, g) }).sum.println
    _ -> "Invalid part!".println
