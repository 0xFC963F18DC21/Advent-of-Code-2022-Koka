module day-input

import std/os/file
import std/os/path
import std/text/parse

pub fun get-input(day: int): <exn, fsys> string
  read-text-file(("./inputs/day" ++ day.show ++ ".txt").path)

pub fun get-input-lines(day: int): <exn, fsys> list<string>
  get-input(day).lines
