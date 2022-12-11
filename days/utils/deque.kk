module deque

// Immutable double-ended unordered queue structure.

pub struct deque<a>
  front: list<a>
  back: list<a>

pub fun deque-from-list(list: list<a>): deque<a>
  match list.split(list.length / 2)
    (xs, sx) -> Deque(xs, sx.reverse)

pub fun deque-to-list(deque: deque<a>): list<a>
  deque.front ++ deque.back.reverse

pub fun deque-empty(): deque<a>
  Deque([], [])

pub fun deque-single(x: a): deque<a>
  Deque([x], [])

/*
 * This data type is subject to two invariances:
 *
 * 1. If front is empty, there is only one item in back, or back is empty.
 * 2. If back is empty, there is only one item in front, or front is empty.
 */

pub fun cons(y: a, ys: deque<a>): deque<a>
  match ys
    Deque(sx, Nil) -> Deque([y], sx)         // By (2), sx is a singleton or empty.
    Deque(xs, sx)  -> Deque(Cons(y, xs), sx) // Both non-empty, so put in front.

pub fun snoc(ys: deque<a>, y: a): deque<a>
  match ys
    Deque(Nil, xs) -> Deque(xs, [y])         // By (1), xs is a singleton or empty.
    Deque(xs, sx)  -> Deque(xs, Cons(y, sx)) // Both non-empty, so put in back.

pub fun dequeue-front(xs: deque<a>): (maybe<a>, deque<a>)
  (xs.head, xs.tail)

pub fun dequeue-back(xs: deque<a>): (deque<a>, maybe<a>)
  (xs.init, xs.last)

pub fun head(ys: deque<a>): maybe<a>
  match ys
    Deque(Nil, Nil)      -> Nothing
    Deque(Cons(x, _), _) -> Just(x)
    Deque(Nil, sx)       -> sx.last

pub fun last(ys: deque<a>): maybe<a>
  match ys
    Deque(Nil, Nil)      -> Nothing
    Deque(_, Cons(x, _)) -> Just(x)
    Deque(xs, Nil)       -> xs.head

// Just like the stdlib, tail acts like identity if the deque is empty.
pub fun tail(ys: deque<a>): deque<a>
  match ys
    Deque(Nil, Nil)         -> Deque(Nil, Nil)
    Deque(Nil, sx)          -> Deque(Nil, sx.init)
    Deque(Cons(_, Nil), sx) -> sx.reverse.deque-from-list
    Deque(xs, sx)           -> Deque(xs.tail, sx)

// Just like the stdlib, init acts like identity if the deque is empty.
pub fun init(ys: deque<a>): deque<a>
  match ys
    Deque(Nil, Nil)         -> Deque(Nil, Nil)
    Deque(xs, Nil)          -> Deque(xs.tail, Nil)
    Deque(xs, Cons(_, Nil)) -> xs.deque-from-list
    Deque(xs, sx)           -> Deque(xs, sx.init)

pub fun (++)(xs: deque<a>, ys: deque<a>): deque<a>
  match (xs, ys)
    (Deque(xs_, sx_), Deque(ys_, sy_)) -> Deque(xs_ ++ sx_.reverse, ys_ ++ sy_.reverse)

pub fun is-empty(xs: deque<a>): bool
  match xs
    Deque(Nil, Nil) -> True
    _               -> False

pub fun is-single(xs: deque<a>): bool
  match xs
    Deque(Cons(_, Nil), Nil) -> True
    Deque(Nil, Cons(_, Nil)) -> True
    _                        -> False

pub fun length(xs: deque<a>): int
  xs.front.length + xs.back.length

pub fun show-deque(deque: deque<a>, show: a -> e string): e string
  "Deque " ++ deque.deque-to-list.show-list(show)
