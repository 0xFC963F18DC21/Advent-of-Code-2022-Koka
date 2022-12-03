module input

import std/os/file
import std/os/path

pub fun to-list-char(slice: sslice): pure list<char>
  match slice.next
    Nothing       -> Nil
    Just((c, cs)) -> Cons(c, cs.to-list-char)

pub fun get-input(day: int): <exn, fsys> string
  read-text-file(("./inputs/day" ++ day.show ++ ".txt").path)

pub fun get-input-lines(day: int): <exn, fsys> list<string>
  get-input(day).lines
