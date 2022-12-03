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

// Flip the order of arguments in a 2-ary function.
pub fun flip(f)
  fn (b, a)
    f(a, b)
