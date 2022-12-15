module main

import std/os/readline

import days/day1
import days/day2
import days/day3
import days/day4
import days/day5
import days/day6
import days/day7
import days/day8
import days/day9
import days/day10
import days/day11
import days/day12
import days/day13
import days/day14

// The runner file for the day solutions.
pub fun main()
  println("Enter a day number to execute:")
  val day  = readline().parse-int-default(0)

  println("")

  println("Enter a part number to execute:")
  val part = readline().parse-int-default(0)

  println("")

  match day
    1  -> day1(part)
    2  -> day2(part)
    3  -> day3(part)
    4  -> day4(part)
    5  -> day5(part)
    6  -> day6(part)
    7  -> day7(part)
    8  -> day8(part)
    9  -> day9(part)
    10 -> day10(part)
    11 -> day11(part)
    12 -> day12(part)
    13 -> day13(part)
    14 -> day14(part)
    _  -> println("Nothing to report on this day...")
