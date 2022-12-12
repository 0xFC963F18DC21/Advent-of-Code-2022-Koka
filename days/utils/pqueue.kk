module pqueue

pub struct heap<a>
  compare: (a, a) -> order
  tree: htree<a>

type htree<a>
  HENil
  HENode(rank: int, left: htree<a>, item: a, right: htree<a>)

fun tree-rank(t: htree<a>): int
  match t
    HENil              -> 0
    HENode(h, _, _, _) -> h

fun heap-rank(h: heap<a>): int
  h.tree.tree-rank

fun henode(l: htree<a>, x: a, r: htree<a>): htree<a>
  if   l.tree-rank <= r.tree-rank
  then HENode(l.tree-rank + 1, r, x, l)
  else HENode(r.tree-rank + 1, l, x, r)

fun heap-merge(l: heap<a>, r: heap<a>): div heap<a>
  Heap(l.compare, tree-merge(l.compare, l.tree, r.tree))

fun tree-merge(compare: (a, a) -> order, l: htree<a>, r: htree<a>): div htree<a>
  match (l, r)
    (_, HENil)                                       -> l
    (HENil, _)                                       -> r
    (HENode(_, ll, lx, lr), HENode(_, rl, rx, rr)) ->
      val c = lx.compare(rx)
      match c
        Gt -> henode(rl, rx, tree-merge(compare, rr, l))
        _  -> henode(ll, lx, tree-merge(compare, lr, r))

pub fun empty(compare: (a, a) -> order): heap<a>
  Heap(compare, HENil)

pub fun is-empty(h: heap<a>): bool
  match h.tree
    HENil -> True
    _     -> False

pub fun enqueue(h: heap<a>, x: a): div heap<a>
  Heap(h.compare, tree-merge(h.compare, h.tree, henode(HENil, x, HENil)))

pub fun peek(h: heap<a>): maybe<a>
  match h
    Heap(_, HENil)              -> Nothing
    Heap(_, HENode(_, _, x, _)) -> Just(x)

pub fun tail(h: heap<a>): div heap<a>
  match h
    Heap(_, HENil)                -> h
    Heap(cmp, HENode(_, l, _, r)) -> Heap(cmp, tree-merge(cmp, l, r))

pub fun dequeue(h: heap<a>): div (maybe<a>, heap<a>)
  (h.peek, h.tail)

fun flt(t: htree<a>, compare: (a, a) -> order, pred: a -> bool): div htree<a>
  match t
    HENil              -> HENil
    HENode(_, l, x, r) ->
      if   x.pred
      then henode(l.flt(compare, pred), x, r.flt(compare, pred))
      else tree-merge(compare, l.flt(compare, pred), r.flt(compare, pred))

pub fun filter(h: heap<a>, pred: a -> bool): div heap<a>
  Heap(h.compare, h.tree.flt(h.compare, pred))
