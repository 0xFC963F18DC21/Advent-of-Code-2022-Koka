module qsort

import ord

// Generalised quicksort.
pub fun qsort-explicit(xxs: list<a>, compare: (a, a) -> order): div list<a>
  with fun cmp(l, r) compare(l, r)
  qsort(xxs)

// Quicksort for types that implement ord with a handler.
pub fun qsort(xxs: list<a>): <div, ord<a>> list<a>
  match xxs
    Nil          -> Nil
    Cons(x, Nil) -> Cons(x, Nil)
    Cons(x, xs)  ->
      match xs.partition(fn (y) { y < x })
        (lts, gts) -> lts.qsort ++ [x] ++ gts.qsort
