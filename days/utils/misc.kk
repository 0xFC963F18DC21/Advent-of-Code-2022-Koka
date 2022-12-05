module misc

// Miscellaneous utilities.

// Partition a list into groups of max size gsize.
pub fun partition-n(xxs: list<a>, gsize: int): pure list<list<a>>
  fun part(xs: list<a>, acc: list<a>, counter: int): pure list<list<a>>
    match xs
      Nil         -> match acc
        Nil -> []
        _   -> [acc.reverse]
      Cons(y, ys) ->
        if   counter == 0
        then Cons(acc.reverse, xs.part(Nil, gsize))
        else ys.part(Cons(y, acc), counter - 1)

  xxs.part(Nil, gsize)

pub fun split-at-first(xxs: list<a>, pred: a -> <pure | e> bool): <pure | e> (list<a>, list<a>)
  fun spl(xs, acc)
    match xs
      Nil         -> (acc.reverse, Nil)
      Cons(y, ys) ->
        if   pred(y)
        then (acc.reverse, ys)
        else ys.spl(Cons(y, acc))

  xxs.spl(Nil)

// Combine effectful computations.
pub fun (<~>)(l: () -> e a, r: () -> e b): e (a, b)
  val lv = l()
  val rv = r()
  (lv, rv)

// Transposes a list of lists.
// Shorter lists can have their elements skipped if you're not careful.
pub fun transpose(xxs: list<list<a>>): pure list<list<a>>
  fun decomp(xss)
    xss.filter-map fn (xs) {
      match xs
        Nil          -> Nothing
        Cons(hd, tl) -> Just((hd, tl))
    }.unzip

  fun comb(y, h, ys, t)
    Cons(Cons(y, h), Cons(ys, t).transpose)

  match xxs
    Nil                    -> Nil
    Cons(Nil, xss)         -> xss.transpose
    Cons(Cons(x, xs), xss) -> match decomp(xss)
      (hds, tls) -> comb(x, hds, xs, tls)

// Flip the order of arguments in a 2-ary function.
pub fun flip(f)
  fn (b, a)
    f(a, b)

// Count the number of elements in a list satisfying some predicate.
pub fun count(xs: list<a>, pred: a -> e bool): e int
  xs.foldl(0) fn (acc, x)
    if   pred(x)
    then acc + 1
    else acc

// Compare implementation for float64.
pub fun compare(l: float64, r: float64): order
  if   l < r then Lt
  elif l > r then Gt
  else            Eq
