module ord

import misc

// The effect of orderable types.
// They should define a cmp function that takes two inputs of the same type,
// and return an ordering information (Lt, Eq, Gt) for that relation.
pub effect ord<a>
  fun cmp(l: a, r: a): order

pub fun (~<)(l: a, r: a): ord<a> bool
  l.cmp(r).is-lt

pub fun (>~)(l: a, r: a): ord<a> bool
  l.cmp(r).is-gt

pub fun (~<=)(l: a, r: a): ord<a> bool
  !(l >~ r)

pub fun (>=~)(l: a, r: a): ord<a> bool
  !(l ~< r)

// Some implementations of ordered types:
pub fun ord-int(action)
  with fun cmp(l: int, r: int) l.compare(r)
  action()

pub fun ord-float64(action)
  with fun cmp(l: float64, r: float64) l.compare(r)
  action()

pub fun ord-char(action)
  with fun cmp(l: char, r: char) l.compare(r)
  action()

pub fun ord-bool(action)
  with fun cmp(l: bool, r: bool) l.compare(r)
  action()

pub fun ord-string(action)
  with fun cmp(l: string, r: string) l.compare(r)
  action()

pub fun ord-list(action)
  fun lcompare(l: list<a>, r: list<a>): <pure, ord<a>> order
    match (l, r)
      (Cons(x, xs), Cons(y, ys)) -> match x.cmp(y)
        Eq -> xs.lcompare(ys)
        or -> or
      (Nil, Nil)                 -> Eq
      (Nil, _)                   -> Lt
      (_, Nil)                   -> Gt

  with fun cmp(l, r) lcompare(l, r)
  action()

pub fun ord-pair(action)
  with fun cmp(l, r)
    match (l, r)
      ((ll, lr), (rl, rr)) -> match ll.cmp(rl)
        Eq -> lr.cmp(rr)
        or -> or

  action()

pub fun ord-triple(action)
  with fun cmp(l, r)
    match (l, r)
      ((l1, l2, l3), (r1, r2, r3)) -> match l1.cmp(r1)
        Eq -> match l2.cmp(r2)
          Eq -> l3.cmp(r3)
          or -> or
        or -> or

  action()

pub fun ord-quadruple(action)
  with fun cmp(l, r)
    match (l, r)
      ((l1, l2, l3, l4), (r1, r2, r3, r4)) -> match l1.cmp(r1)
        Eq -> match l2.cmp(r2)
          Eq -> match l3.cmp(r3)
            Eq -> l4.cmp(r4)
            or -> or
          or -> or
        or -> or

  action()
