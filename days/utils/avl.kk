module avl

// AVL search tree.
pub type avltree<a, b>
  HTip
  HNode(h: int, l: avltree<a, b>, key: a, value: b, r: avltree<a, b>)

pub fun height(t: avltree<a, b>): int
  match t
    HTip                 -> 0
    HNode(h, _, _, _, _) -> h

fun hnode(l: avltree<a, b>, k: a, v: b, r: avltree<a, b>): avltree<a, b>
  HNode(max(l.height, r.height) + 1, l, k, v, r)

// Copied pattern from the rbtree-fbip example.
// The zipper pattern allows Koka to do things IN-PLACE.
type avlzipper<a, b>
  Done
  HNodeL(zip: avlzipper<a, b>, h: int, key: a, value: b, r: avltree<a, b>)
  HNodeR(l: avltree<a, b>, key: a, value: b, h: int, zip: avlzipper<a, b>)

fun avl-move-up(z: avlzipper<a, b>, t: avltree<a, b>): avltree<a, b>
  match z
    Done                -> t
    HNodeL(zl, _, k, v, r) -> zl.avl-move-up(hnode(t, k, v, r))
    HNodeR(l, k, v, _, zr) -> zr.avl-move-up(hnode(l, k, v, t))

fun avl-balance(z: avlzipper<a, b>, l: avltree<a, b>, k: a, v: b, r: avltree<a, b>): avltree<a, b>
  match z
    Done                        ->
      // We're done.
      hnode(l, k, v, r)
    HNodeL(zl, zlh, k_, v_, r_) ->
      // This current node is the parent's left child.
      if zlh - r_.height > 1 then
        // Left-heavy, so rotate right.
        zl.avl-balance(l, k, v, hnode(r, k_, v_, r_))
      else
        // Balanced, or right-heavy one-level up.
        zl.avl-balance(hnode(l, k, v, r), k_, v_, r_)
    HNodeR(l_, k_, v_, zrh, zr) ->
      // This current node is the parent's right child.
      if zrh - l_.height > 1 then
        // Right-heavy, so rotate left.
        zr.avl-balance(hnode(l_, k_, v_, l), k, v, r)
      else
        // Balanced, or left-heavy one-level up.
        zr.avl-balance(l_, k_, v_, hnode(l, k, v, r))

fun avl-ins(t: avltree<a, b>, key: a, value: b, compare: (a, a) -> e order, z: avlzipper<a, b>): e avltree<a, b>
  match t
    HTip              -> z.avl-balance(HTip, key, value, HTip)
    HNode(_, l, k, v, r) ->
      if   key.compare(k).is-lt then avl-ins(l, key, value, compare, HNodeL(z, l.height, k, v, r))
      elif key.compare(k).is-gt then avl-ins(r, key, value, compare, HNodeR(l, k, v, r.height, z))
      else                           z.avl-move-up(hnode(l, k, v, r))

pub fun avl-insert(t: avltree<a, b>, key: a, value: b, compare: (a, a) -> e order): e avltree<a, b>
  avl-ins(t, key, value, compare, Done)

pub fun avl-get(t: avltree<a, b>, key: a, default: b, compare: (a, a) -> e order): e b
  match t
    HTip                 -> default
    HNode(_, l, k, x, r) -> match key.compare(k)
      Eq -> x
      Lt -> l.avl-get(key, default, compare)
      Gt -> r.avl-get(key, default, compare)

fun min-pair(t: avltree<a, b>): exn (a, b)
  match t
    HNode(_, HTip, k, v, _) -> (k, v)
    HNode(_, l, _, _)       -> l.min-pair

fun avl-del(t: avltree<a, b>, key: a, compare: (a, a) -> <exn | e> order, z: avlzipper<a, b>): <exn | e> avltree<a, b>
  match t
    HTip                 -> z.avl-move-up(HTip)
    HNode(_, l, k, v, r) -> match key.compare(k)
      Lt -> avl-del(l, key, compare, HNodeL(z, l.height, k, v, r))
      Gt -> avl-del(r, key, compare, HNodeR(l, k, v, r.height, z))
      Eq -> match t
        HNode(_, HTip, _, _, HTip)                     -> z.avl-move-up(HTip)
        HNode(_, HNode(_, ll, kk, vv, rr), _, _, HTip) -> z.avl-balance(ll, kk, vv, rr)
        HNode(_, HTip, _, _, HNode(_, ll, kk, vv, rr)) -> z.avl-balance(ll, kk, vv, rr)
        _                                              -> match r.min-pair
          (mk, mv) -> z.avl-balance(l, mk, mv, r.avl-delete(mk, compare))

pub fun avl-delete(t: avltree<a, b>, key: a, compare: (a, a) -> <exn | e> order): <exn | e> avltree<a, b>
  avl-del(t, key, compare, Done)

pub fun fold(t: avltree<a, b>, acc: c, f: (a, b, c) -> e c): e c
  match t
    HTip                 -> acc
    HNode(_, l, k, v, r) -> r.fold(f(k, v, l.fold(acc, f)), f)

pub fun count(t: avltree<a, b>): int
  t.fold(0) fn (k, v, r)
    r + 1

pub fun get-any(t: avltree<a, b>): maybe<(a, b)>
  match t
    HTip                 -> Nothing
    HNode(_, _, k, v, _) -> Just((k, v))