module day-utils

import std/text/parse

// Generalised quicksort.
pub fun qsort(xxs: list<a>, compare: (a, a) -> order): div list<a>
  match xxs
    Nil          -> Nil
    Cons(x, Nil) -> Cons(x, Nil)
    Cons(x, xs)  ->
      fun leq-x(y): bool
        match y.compare(x)
          Eq -> True
          Lt -> True
          Gt -> False

      match xs.partition(leq-x)
        (lts, gts) -> lts.qsort(compare) ++ [x] ++ gts.qsort(compare)

// Flip the order of arguments in a 2-ary function.
pub fun flip(f)
  fn (b, a)
    f(a, b)
