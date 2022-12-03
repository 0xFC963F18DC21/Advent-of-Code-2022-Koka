module set

import avl
import ord

// Specialisation of AVL trees, used as a set.
pub alias set<a> = avltree<a, bool>

// Empty set.
pub fun empty(): set<a>
  HTip

// Does not insert if the item already exists.
pub fun insert(set: set<a>, x: a, compare: (a, a) -> e order): e set<a>
  set.avl-insert(x, True, compare)

pub fun insert(set: set<a>, x: a): ord<a> set<a>
  set.insert(x, cmp)

// Returns false if item not in set.
pub fun contains(set: set<a>, x: a, compare: (a, a) -> e order): e bool
  set.avl-get(x, False, compare)

pub fun contains(set: set<a>, x: a): ord<a> bool
  set.contains(x, cmp)

// Set union.
pub fun union(l: set<a>, r: set<a>, compare: (a, a) -> e order): e set<a>
  r.fold(l) fn (k, v, acc) {
    acc.avl-insert(k, v, compare)
  }

pub fun union(l: set<a>, r: set<a>): ord<a> set<a>
  l.union(r, cmp)

// Set intersection.
pub fun intersect(l: set<a>, r: set<a>, compare: (a, a) -> e order): e set<a>
  l.fold(empty()) fn (k, _, acc) {
    if   r.contains(k, compare)
    then acc.insert(k, compare)
    else acc
  }

pub fun intersect(l: set<a>, r: set<a>): ord<a> set<a>
  l.intersect(r, cmp)

// Returns the same set if no item was removed.
pub fun remove(set: set<a>, x: a, compare: (a, a) -> <pure | e> order): <pure | e> set<a>
  set.avl-delete(x, compare)

pub fun remove(set: set<a>, x: a): <pure, ord<a>> set<a>
  set.remove(x, cmp)

// Get the number of items in the set.
pub fun set-count(set: set<a>): int
  set.count

// Returns any item in the set, usually the set tree's root.
pub fun any(set: set<a>): maybe<(a, bool)>
  set.get-any()
