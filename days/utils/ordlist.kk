module ordlist

import ord

// Generalised quicksort.
pub fun qsort(xxs: list<a>, compare: (a, a) -> <div | e> order): <div | e> list<a>
  with fun cmp(l, r) compare(l, r)
  qsort(xxs)

// Quicksort for types that implement ord with a handler.
pub fun qsort(xxs: list<a>): <div, ord<a>> list<a>
  match xxs
    Nil          -> Nil
    Cons(x, Nil) -> Cons(x, Nil)
    Cons(x, xs)  ->
      match xs.partition(fn (y) { y ~< x })
        (lts, gts) -> lts.qsort ++ Cons(x, gts.qsort)

// Min and Max functions.
pub fun minimum-by(xxs: list<a>): <pure, ord<a>> a
  match xxs
    Nil -> throw("There is nothing here.")
    _   -> xxs.foldl1 fn (cur, next)
      if next ~< cur then next else cur

pub fun maximum-by(xxs: list<a>): <pure, ord<a>> a
  match xxs
    Nil -> throw("There is nothing here.")
    _   -> xxs.foldl1 fn (cur, next)
      if next >~ cur then next else cur

pub fun minimum-by(xxs: list<a>, compare: (a, a) -> <pure | e> order): <pure | e> a
  with fun cmp(l, r) compare(l, r)
  minimum-by(xxs)

pub fun maximum-by(xxs: list<a>, compare: (a, a) -> <pure | e> order): <pure | e> a
  with fun cmp(l, r) compare(l, r)
  maximum-by(xxs)
