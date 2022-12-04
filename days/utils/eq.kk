module eq

import ord

// The effect of equatable types.
// There is no preference for structural / referential equality,
// however, said impls should be separated.
pub effect eq<a>
  fun eq(l: a, r: a): bool

pub fun (==)(l: a, r: a): eq<a> bool
  l.eq(r)

pub fun (!=)(l: a, r: a): eq<a> bool
  !(l.eq(r))

// Some implementations of equatable types:
pub fun eq-int(action)
  with fun eq(l: int, r: int) l.compare(r).is-eq
  action()

pub fun eq-char(action)
  with fun eq(l: char, r: char) l.compare(r).is-eq
  action()

pub fun eq-bool(action)
  with fun eq(l: bool, r: bool) l.compare(r).is-eq
  action()

pub fun eq-string(action)
  with fun eq(l: string, r: string) l.compare(r).is-eq
  action()

pub fun eq-list(action)
  fun list-eq(l: list<a>, r: list<a>): <pure, eq<a>> bool
    match (l, r)
      (Cons(x, xs), Cons(y, ys)) -> x.eq(y) && xs.list-eq(ys)
      (Nil, Nil)                 -> True
      (Nil, _)                   -> False
      (_, Nil)                   -> False

  with fun eq(l, r) list-eq(l, r)
  action()

pub fun eq-pair(action)
  with fun eq(l, r)
    match (l, r)
      ((ll, lr), (rl, rr)) ->
        ll.eq(rl) && lr.eq(rr)

  action()

pub fun eq-triple(action)
  with fun eq(l, r)
    match (l, r)
      ((l1, l2, l3), (r1, r2, r3)) ->
        l1.eq(r1) && l2.eq(r2) && l3.eq(r3)

  action()

pub fun eq-quadruple(action)
  with fun eq(l, r)
    match (l, r)
      ((l1, l2, l3, l4), (r1, r2, r3, r4)) ->
        l1.eq(r1) && l2.eq(r2) && l3.eq(r3) && l4.eq(r4)

  action()

// All orderables are implicitly equatable.
pub fun eq-ord(action)
  with fun eq(l, r) l.cmp(r).is-eq
  action()
