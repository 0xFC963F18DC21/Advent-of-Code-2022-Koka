module day-utils

import std/text/parse

// Generalised quicksort.
pub fun qsort(xxs: list<a>, compare: (a, a) -> order): div list<a>
  match xxs
    Nil          -> Nil
    Cons(x, Nil) -> Cons(x, Nil)
    Cons(x, xs)  ->
      match xs.partition(fn (y) {
        match x.compare(y)
          Eq -> True
          Lt -> True
          Gt -> False
      })
        (lts, gts) -> lts.qsort(compare) ++ [x] ++ gts.qsort(compare)
