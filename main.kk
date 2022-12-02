module main

import std/os/readline

import days/day1
import days/day2

// The runner file for the day solutions.
pub fun main()
  println("Enter a day number to execute:")
  val day  = readline().parse-int-default(0)

  println("")

  println("Enter a part number to execute:")
  val part = readline().parse-int-default(0)

  println("")

  match day
    1 -> day1(part)
    2 -> day2(part)
    _ -> println("Nothing to report on this day...")